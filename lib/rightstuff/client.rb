require 'rubygems' if RUBY_VERSION < '1.9'
require 'nokogiri'
require 'net/https'
require 'uri'

module Rightstuff

  class Client

    def initialize( options = {} )
      @username = options[ :username ] or raise 'no username supplied'
      @password = options[ :password ] or raise 'no password supplied'
      @account  = options[ :account ]  or raise 'no account id supplied'
      @account = @account.to_s

      @base_url               = 'https://my.rightscale.com/api/acct'
      url                     = URI.parse( @base_url )
      @connection             = Net::HTTP.new( url.host, url.port )
      @connection.use_ssl     = true
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def get_rest( rest )
      get( account_url( rest ) )
    end

    def servers
      return @servers if @servers
      body     = Nokogiri::XML( get_rest( 'servers' ) )
      @servers = Server.load_collection( self, body )
    end

    private

    def get( address )
      url     = URI.parse( address )
      request = Net::HTTP::Get.new( url.request_uri )
      request.add_field( 'X-API-VERSION', '1.0' )
      request.basic_auth( @username, @password )

      response = @connection.request( request )

      case response.code
      when '200'
        return response.body
      else
        raise "Request '#{ address }' failed with response code #{ response.code }\n#{ response.body }"
      end
    end

    def account_url( rest )
      @base_url + '/' + @account + '/' + rest
    end

  end

end
