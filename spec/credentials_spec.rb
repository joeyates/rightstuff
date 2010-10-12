SPEC_PATH = File.expand_path( File.dirname( __FILE__ ) )
ROOT_PATH = File.dirname( SPEC_PATH )
require File.join( ROOT_PATH, 'lib', 'rightstuff' )

require 'fileutils'
require 'yaml'

class CredentialsUser
  include Rightstuff::Credentials
end

describe Rightstuff::Credentials do

  after( :each ) do
    FileUtils.rm_f test_credentials_path
  end

  it "loads credentials" do
    create_test_credentials( { :my_creds => { :username => 'myuser', :password => 'secret' } }.to_yaml )
    cred = CredentialsUser.new
    cred.stub!( :rightscale_data_path ).and_return( test_credentials_path )

    data = nil
    lambda do
      data = cred.rightscale_data
    end.should_not raise_error
    data[ :my_creds ].should == { :username => 'myuser', :password => 'secret' }
  end

  it "fails if permissions are too open" do
    create_test_credentials( {}.to_yaml, 0666 )
    cred = CredentialsUser.new
    cred.stub!( :rightscale_data_path ).and_return( test_credentials_path )

    data = nil
    lambda do
      data = cred.rightscale_data
    end.should raise_error( RuntimeError, /Permissions.*?too open/ )
  end

  it "fails if file is missing" do
    cred = CredentialsUser.new
    cred.stub!( :rightscale_data_path ).and_return( test_credentials_path )

    data = nil
    lambda do
      data = cred.rightscale_data
    end.should raise_error( RuntimeError, /Missing credentials file/ )
  end

  it "fails if data is not YAML" do
    create_test_credentials( ":" )
    cred = CredentialsUser.new
    cred.stub!( :rightscale_data_path ).and_return( test_credentials_path )

    data = nil
    lambda do
      data = cred.rightscale_data
    end.should raise_error( ArgumentError, /syntax error/ )
  end

  private

  def test_credentials_path
    '/tmp/.rightstuff'
  end

  def create_test_credentials( data, permissions = 0600 )
    File.open( test_credentials_path, 'w+' ) do | file |
      file.puts data
    end
    FileUtils.chmod permissions, test_credentials_path
  end

end
