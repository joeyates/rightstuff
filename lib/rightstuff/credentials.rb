require 'yaml'

module Rightstuff

  # Rightstuff::Credentials imposes no restrictions on the structure of the data
  # It only requires that:
  #  1. the user has a file called ~/.rightstuff,
  #  2. the file contains YAML::load-able data.
  #  3. the the file does not have any permissions for other users,
  module Credentials

    def rightscale_data
      return @rightscale_data if @rightscale_data
      raise "Missing credentials file '#{ rightscale_data_path }'" if ! File.exist?( rightscale_data_path )
      check_permissions
      @rightscale_data = YAML.load_file( rightscale_data_path )
    end

    private

    def rightscale_data_path
      File.expand_path( '~/.rightstuff' )
    end

    def check_permissions
      mode = File::Stat.new( rightscale_data_path ).mode
      if mode & 0066 != 0
        raise "Permissions on '#{ rightscale_data_path }' too open (currently 0%o), should be 0600" % ( mode & 0666 )
      end
    end

  end

end
