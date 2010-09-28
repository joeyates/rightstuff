require 'rubygems' if RUBY_VERSION < '1.9'
require 'yaml'
require 'net/https'
require 'uri'
require 'nokogiri'

module Rightstuff

  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 0
    TINY  = 2
 
    STRING = [ MAJOR, MINOR, TINY ].join('.')
  end

  module Credentials

    def rightscale_data_path
      File.expand_path( '~/.rightscale' )
    end

    def check_permissions
      mode = File::Stat.new( rightscale_data_path ).mode
      if mode & 0066 != 0
        raise "Permissions on '#{ rightscale_data_path }' too open (currently 0%o), should be 0600" % ( mode & 0666 )
      end
    end

    def rightscale_data
      return @rightscale_data if @rightscale_data
      raise "Missing credentials file '#{ rightscale_data_path }'" if ! File.exist?( rightscale_data_path )
      check_permissions
      @rightscale_data = YAML.load_file( rightscale_data_path )
    end

  end

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

    def initialize( client, item )
      @client     = client
      @attributes = Base.extract_attributes( item )
    end

    def method_missing( name, *args, &block )
      return @attributes[ name ]
    end

  end

  class Server < Base
    
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
      doc      = @client.get_rest( 'servers/' + id + '/settings' )
      xml      = Nokogiri::XML( doc )
      @settings = Base.extract_attributes( xml.children )
      @attributes.merge!( settings )
    end

  end

  class Client

    def initialize( options = {} )
      @base_url = 'https://my.rightscale.com/api/acct'
      @username = options[ :username ] or raise 'no username supplied'
      @password = options[ :password ] or raise 'no password supplied'
      @account  = options[ :account ]  or raise 'no account id supplied'
      @account = @account.to_s
    end

    def get_rest( rest )
      get( account_url( rest ) )
    end

    def get( path )
      address         = path
      url             = URI.parse( address )
      con             = Net::HTTP.new( url.host, url.port )
      con.use_ssl     = true
      con.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request         = Net::HTTP::Get.new( url.request_uri )
      request.add_field( 'X-API-VERSION', '1.0' )
      request.basic_auth @username, @password

      response = con.request( request )

      case response.code
      when '200'
        return response.body
      else
        raise "Request '#{ address }' failed with response code #{ response.code }\n#{ response.body }"
      end
    end

    def servers
      body = Nokogiri::XML( get_rest( 'servers' ) )
      Server.load_collection( self, body )
    end

    def account_url( rest )
      @base_url + '/' + @account + '/' + rest
    end

  end

end
