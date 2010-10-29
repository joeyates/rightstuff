require 'rubygems' if RUBY_VERSION < '1.9'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
$:.unshift( File.dirname( __FILE__ ) + '/lib' )
require 'rightstuff'

spec = eval(File.read("rightstuff.gemspec"))

Rake::GemPackageTask.new( spec ) do |pkg|
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir      = 'html'
  rdoc.options       += RDOC_OPTS
  rdoc.title         = DESCRIPTION
  rdoc.rdoc_files.add RDOC_FILES
end
