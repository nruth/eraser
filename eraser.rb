require "rubygems"
require "bundler/setup"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'lib','**','*.rb'))].each {|f| require f}
