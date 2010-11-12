require 'rubygems' if RUBY_VERSION < '1.9'
require 'nokogiri'

module Rightstuff

  class Base

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

    def method_missing( name, *args, &block )
      return @attributes[ name ]
    end

  end

end
