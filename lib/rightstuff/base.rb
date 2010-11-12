require 'rubygems' if RUBY_VERSION < '1.9'
require 'active_support/all'
require 'nokogiri'

module Rightstuff

  class Base

    def self.type
      name.demodulize.underscore
    end

    def self.collection_xpath
      "/#{ type.pluralize }/#{ type }"
    end

    def self.load_collection( client, doc )
      doc.xpath( self.collection_xpath ).collect do | item |
        self.new( client, item )
      end
    end

    def self.extract_attributes( parent )
      elements = parent.children.collect do | node |
        node.class == Nokogiri::XML::Element ? node : nil
      end
      elements.compact!
      elements.reduce( {} ) do | memo, element |
        name = element.name
        name.gsub!( /-/, '_' )
        memo[ name.intern ] = element.children[ 0 ].to_s
        memo
      end
    end

    attr_reader :attributes

    def initialize( client, item )
      @client     = client
      @attributes = Base.extract_attributes( item )
    end

    def id
      @attributes[ :href ].split( '/' ).last
    end

    def method_missing( name , *args, &block )
      result = super
      return result unless result.nil?
      return nil    if ! active?
      return @attributes[ name ]
    end

    def method_missing( name, *args, &block )
      return @attributes[ name ]
    end

  end

end
