require "rubygems"
require "bundler/setup"

require "backports/1.9.2"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'lib','**','*.rb'))].each {|f| require f}
