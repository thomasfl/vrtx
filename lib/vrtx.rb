# -*- coding: utf-8 -*-
require 'davclient'
require 'time'

# Command line utility for Vortex CMS
#
# Library for communicating with Vortex CMS server via WebDAV protocol.
#
# Documentation for vortex specific properties, see "Resource type tree":
# http://www.usit.uio.no/it/vortex/arbeidsomrader/metadata/ressurstypetre-2009-06-15.txt

ARTICLE_HTML = <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>##title##</title>
</head>
<body>
  <p>##content##</p>
</body>
</html>
EOF

article_props = <<EOF
    <v:resourceType xmlns:v="vrtx">article</v:resourceType>
    <v:xhtml10-type xmlns:v="vrtx">article</v:xhtml10-type>
    <v:published-date xmlns:v="vrtx">##published-date##</v:published-date>
    <v:userSpecifiedCharacterEncoding xmlns:v="vrtx">##characterEncoding##</v:userSpecifiedCharacterEncoding>
    <v:userTitle xmlns:v="vrtx">##usertitle##</v:userTitle>
EOF

ARTICLE_PROPERTIES = article_props.gsub("\n","").gsub(/ +/," ")

authors_props = <<EOF
    <v:authors xmlns:v="vrtx">
      <vrtx:values xmlns:vrtx="http://vortikal.org/xml-value-list">
        <vrtx:value>##realname##</vrtx:value>
      </vrtx:values>
    </v:authors>
EOF
AUTHORS = authors_props.gsub("\n","").gsub(/ +/," ")

INTRODUCTION = "<introduction>##introduction##</introduction>"

# Utilities for communicating with the Vortex CMS through
# the WebDAV server interface
module Vortex

  # TODO: Set a list of default priority xml namespace prefixes
  #       Can be done by monkey patching WebDAV module

  $defaultCharacterEncoding = 'utf-8'


  # Convert WebDAV URL to public web URL
  # Examples:
  #   davUrl2webUrl("https://www-dav.uio.no/faq/it/basware.xml") =>  "http://www.uio.no/faq/it/basware.xml"
  def self.davUrl2webUrl(url)
    if(url =~ /^https:\/\/([^\/]*)-dav(\..*)/)then
      return "http://" + $1 + $2
    end
  end

  # Convert public/non-webdav url's to vortex-webdav-url's
  def self.url2davUrl(url)
    if(url =~ /^http:\/\/([^.]*)(\..*)/) then
      return "https://" + $1 + "-dav" + $2
    end
  end


  # Parse datestring
  # Example:
  #   Recognizes "19.04.2009 12:00"
  def self.parse_datestring(datestring)
    # puts "DEBUG:" + datestring.class.to_s

    if(datestring =~ /\d\d\.\d\d\.\d\d\d\d \d\d:\d\d/)then
      date = DateTime.strptime(datestring, "%d.%m.%Y %H:%M")
      # Regexp'en er et hack for å unngå at kl. 12:00 som input returnerer kl.14:00.
      # Denne koden virker bare i norge. Trenger en måte å få lest ut tidssone på.
      time = Time.parse(date.to_s.gsub(/\+00:00/,"+02:00"))
      return time
    end

    return Time.parse(datestring)
  end

  # Publish article to Vortex CMS through WebDAV server.
  def self.publish_article(url, title, introduction, content, published_date, *args)

    if(not published_date)then
      published_date = Time.now
    end
    if(published_date.class == String )
      published_date = self.parse_datestring(published_date)
    end
    if(not title)then
      title = ""
    end

    if(content =~ /\<html/ ) then
      html = content
    else
      html = ARTICLE_HTML.gsub(/##title##/, title).gsub(/##content##/, content)
    end

    properties = ARTICLE_PROPERTIES.gsub(/##published-date##/, published_date.httpdate.to_s)
    properties = properties.gsub(/##usertitle##/, title)

    characterEncoding = $defaultCharacterEncoding

    if(args)then
      options = args[0]

      if(options[:visualProfile] != nil and options[:visualProfile]== false)
        # Default is true
        properties += "<disabled xmlns=\"http://www.uio.no/visual-profile\">true</disabled>"
      end

      if(options[:authors])then
        properties += AUTHORS.gsub(/##realname##/, options[:authors])
      end

      if(options[:owner])then
        owner = options[:owner]
        if(not owner =~ /@/)then
          owner = owner + "@uio.no"
        end
        properties += "<v:owner xmlns:v=\"vrtx\">#{owner}</v:owner>"
      end

      if(options[:createdBy])then
        createdBy = options[:createdBy]
        if(not createdBy =~ /@/)then
          createdBy = createdBy + "@uio.no"
        end
        properties += "<v:createdBy xmlns:v=\"vrtx\">#{createdBy}</v:createdBy>"
      end

      if(options[:contentModifiedBy])then
        contentModifiedBy = options[:contentModifiedBy]
        if(not contentModifiedBy =~ /@/)then
          contentModifiedBy = contentModifiedBy + "@uio.no"
        end
        properties += "<v:contentModifiedBy xmlns:v=\"vrtx\">#{contentModifiedBy}</v:contentModifiedBy>"
      end

      if(options[:propertiesModifiedBy])then
        propertiesModifiedBy = options[:propertiesModifiedBy]
        if(not propertiesModifiedBy =~ /@/)then
          propertiesModifiedBy = propertiesModifiedBy + "@uio.no"
        end
        properties += "<v:propertiesModifiedBy xmlns:v=\"vrtx\">#{propertiesModifiedBy}</v:propertiesModifiedBy>"
      end

      if(options[:modifiedBy])then
        modifiedBy = options[:modifiedBy]
        if(not modifiedBy =~ /@/)then
          modifiedBy = modifiedBy + "@uio.no"
        end
        properties += "<v:contentModifiedBy xmlns:v=\"vrtx\">#{modifiedBy}</v:contentModifiedBy>"
        properties += "<v:propertiesModifiedBy xmlns:v=\"vrtx\">#{modifiedBy}</v:propertiesModifiedBy>"
      end

      if(options[:characterEncoding])then
        characterEncoding = options[:characterEncoding]
      end

      if(options[:contentLastModified])then
        contentLastModified = options[:contentLastModified]
        if(contentLastModified.class == String )
          contentLastModified = self.parse_datestring(contentLastModified)
        end
        properties += "<v:contentLastModified xmlns:v=\"vrtx\">#{contentLastModified.httpdate.to_s}</v:contentLastModified>"
      end


      if(options[:propertiesLastModified])then
        propertiesLastModified = options[:propertiesLastModified]
        if(propertiesLastModified.class == String )
          propertiesLastModified = self.parse_datestring(propertiesLastModified)
        end
        properties += "<v:propertiesLastModified xmlns:v=\"vrtx\">#{propertiesLastModified.httpdate.to_s}</v:propertiesLastModified>"
      end

      if(options[:creationDate])then
        creationDate = options[:creationDate]

        if(creationDate.class == Time)then
          creationDateString = creationDate.httpdate.to_s ## xmlschema.to_s
        end

        if(creationDate.class == String)then
          creationDateString = parse_datestring(creationDate).httpdate.to_s
        end

        properties += "<v:creationTime>#{creationDateString}</v:creationTime>"
      end

    end

    properties = properties.gsub(/##characterEncoding##/, characterEncoding )

    if(introduction) then
      if(not introduction =~ /^<p>/)then
        introduction = "<p>" + introduction + "</p>"
      end
      introduction = introduction.gsub(/</,"&lt;").gsub(/>/,"&gt;")
      properties = properties + INTRODUCTION.gsub(/##introduction##/, introduction)
      properties = properties.gsub("\n","").gsub(/ +/," ")
    end

    WebDAV.publish(url, html, properties )
    return true
  end

  class Article

    def initalize(url, *args)
    end

    def method_missing(method_name, *args)
      # Detect   article.createdBy = thomasfl
    end

    def update()
      # Proppatch
    end

  end

end
