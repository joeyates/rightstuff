SPEC_PATH = File.expand_path( File.dirname( __FILE__ ) )
ROOT_PATH = File.dirname( SPEC_PATH )
require File.join( ROOT_PATH, 'lib', 'rightstuff' )

describe Rightstuff::Client, 'instantiation' do

  it "fails if no username is suplied" do
    lambda do
      Rightstuff::Client.new( { :password => 'secret' } )
    end.should raise_error( RuntimeError, /no username/ )
  end

  it "fails if no password is suplied" do
    lambda do
      Rightstuff::Client.new( { :username => 'me' } )
    end.should raise_error( RuntimeError, /no password/ )
  end

  it "fails if no account is suplied" do
    lambda do
      Rightstuff::Client.new( { :username => 'me', :password => 'secret' } )
    end.should raise_error( RuntimeError, /no account/ )
  end

end

describe Rightstuff::Client, 'get_rest' do

  before( :each ) do
    @http_mock = mock( Net::HTTP, :use_ssl= => nil, :verify_mode= => nil )
    Net::HTTP.stub!( :new ).and_return( @http_mock )

    @client   = Rightstuff::Client.new( { :username => 'me', :password => 'secret', :account => 'aaa' } )
  end

  it "constructs request URLs correctly" do
    mock_get      = mock( Net::HTTP::Get, :add_field => nil, :basic_auth => nil )
    mock_response = mock( 'response', :code => '200', :body => '<foobars/>' )
    @http_mock.stub!( :request ).and_return( mock_response )

    Net::HTTP::Get.should_receive( :new ).with( '/api/acct/aaa/foobars' ).and_return( mock_get )
    @client.get_rest( 'foobars' )
  end

  it "should return the response body" do
    mock_get      = mock( Net::HTTP::Get, :add_field => nil, :basic_auth => nil )
    mock_response = mock( 'response', :code => '200', :body => 'the response' )
    @http_mock.stub!( :request ).and_return( mock_response )
    Net::HTTP::Get.stub!( :new ).with( anything ).and_return( mock_get )

    @client.get_rest( 'foobars' ).should == 'the response'
  end

  it "should fail if the response code is not 200" do
    mock_get      = mock( Net::HTTP::Get, :add_field => nil, :basic_auth => nil )
    mock_response = mock( 'response', :code => '404', :body => nil )
    @http_mock.stub!( :request ).and_return( mock_response )
    Net::HTTP::Get.stub!( :new ).with( anything ).and_return( mock_get )

    lambda do
      @client.get_rest( 'foobars' )
    end.should raise_error( RuntimeError, /failed with response code 404/ )
  end

end

describe Rightstuff::Client, 'servers' do

  before( :each ) do
    @http_mock = mock( Net::HTTP, :use_ssl= => nil, :verify_mode= => nil )
    Net::HTTP.stub!( :new ).and_return( @http_mock )

    @client       = Rightstuff::Client.new( { :username => 'me', :password => 'secret', :account => 'aaa' } )
    @mock_get     = mock( Net::HTTP::Get, :add_field => nil, :basic_auth => nil )
    mock_response = mock( 'response', :code => '200', :body => '<servers/>' )
    @http_mock.stub!( :request ).and_return( mock_response )
  end

  it "should query RightScale for the server list" do
    Net::HTTP::Get.should_receive( :new ).with( '/api/acct/aaa/servers' ).and_return( @mock_get )
    @client.servers
  end

  it "should instantiate a list of servers via Rightstuff::Server::load_collection" do
    Net::HTTP::Get.stub!( :new ).and_return( @mock_get )
    Rightstuff::Server.should_receive( :load_collection ).with( @client, anything )

    @client.servers
  end

end
