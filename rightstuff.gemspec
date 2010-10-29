lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'rightstuff'

ADMIN_FILES          = [ 'COPYING', 'Rakefile', 'README.rdoc' ]
SOURCE_FILES         = Dir.glob('lib/**/*.rb')
RDOC_FILES           = [ 'COPYING', 'README.rdoc' ] + SOURCE_FILES
RDOC_OPTS            = [ '--quiet', '--main', 'README.rdoc', '--inline-source' ]
DESCRIPTION          = 'Another Ruby Interface for RightScale, providing an OO interface for RightScale accounts'

Gem::Specification.new do |s|
  s.name             = 'rightstuff'
  s.summary          = 'Another Ruby Interface for RightScale'
  s.description      = DESCRIPTION
  s.version          = Rightstuff::VERSION::STRING

  s.homepage         = 'http://github.com/joeyates/rightstuff'
  s.author           = 'Joe Yates'
  s.email            = 'joe.g.yates@gmail.com'

  s.files            = ADMIN_FILES +
                       SOURCE_FILES
  s.require_paths    = [ 'lib' ]
  s.add_dependency( 'nokogiri', '>= 1.4.3.1' )

  s.has_rdoc         = true
  s.rdoc_options     += RDOC_OPTS
  s.extra_rdoc_files = RDOC_FILES
  s.rubyforge_project = 'nowarning'
end
