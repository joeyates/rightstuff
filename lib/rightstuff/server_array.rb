module Rightstuff
  # http://support.rightscale.com/15-References/RightScale_API_Reference_Guide/02-Management/09-Server_Arrays
  class ServerArray < Base

    def initialize( client, item )
      @inputs    = nil
      @instances = nil
      super
    end

    def active?
      @attributes[ :state ] != 'stopped'
    end

    def inputs
      return @inputs if @inputs
      # Add inputs to instance data
      # @client.get( @attributes[ 'href' ] )
    end

    def instances
      return @instances if @instances
      body     = Nokogiri::XML( @client.get_rest( "#{ type.pluralize }/#{ id }/instances" ) )
      @instances = Rightstuff::ArrayInstance.load_collection( @client, body )
    end
  end

end
