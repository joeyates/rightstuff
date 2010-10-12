module Rightstuff

  class Server < Base

    attr_reader :attributes

    def initialize( client, item )
      @settings = nil
      @inputs   = nil
      super
    end

    def self.collection_xpath
      '/servers/server'
    end

    def method_missing( name , *args, &block )
      result = super
      return result unless result.nil?
      return nil    unless @attributes[ :state ] == 'operational'
      settings unless @settings
      return @attributes[ name ]
    end

    def id
      @attributes[ :href ].split( '/' ).last
    end

    def inputs
      return @inputs if @inputs
      # Add inputs to instance data
      # @client.get( @attributes[ 'href' ] )
    end

    def settings
      return @settings if @settings
      doc       = @client.get_rest( 'servers/' + id + '/settings' )
      xml       = Nokogiri::XML( doc )
      @settings = Base.extract_attributes( xml.children )
      @attributes.merge!( @settings )
    end

  end

end
