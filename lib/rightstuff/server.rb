module Rightstuff
  # http://support.rightscale.com/15-References/RightScale_API_Reference_Guide/02-Management/02-Servers
  class Server < Base

    attr_reader :attributes

    def initialize( client, item )
      @settings = nil
      @inputs   = nil
      super
    end

    def active?
      @attributes[ :state ] == 'operational'
    end

    def inputs
      return @inputs if @inputs
      # Add inputs to instance data
      # @client.get( @attributes[ 'href' ] )
    end

    def settings
      return @settings if @settings
      doc       = @client.get_rest( "#{ type.pluralize }/#{ id }/settings" )
      xml       = Nokogiri::XML( doc )
      @settings = Base.extract_attributes( xml.children )
      @attributes.merge!( @settings )
    end

  end

end
