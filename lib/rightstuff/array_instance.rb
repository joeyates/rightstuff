module Rightstuff
  # http://support.rightscale.com/15-References/RightScale_API_Reference_Guide/02-Management/09-Server_Arrays
  class ArrayInstance < Base

    attr_reader :attributes

    def initialize( client, item )
      @inputs   = nil
      super
    end

    def self.collection_xpath
      '/instances/instance'
    end

    def method_missing( name , *args, &block )
      result = super
      return result unless result.nil?
      return nil    if @attributes[ :state ] == 'stopped'
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

  end

end
