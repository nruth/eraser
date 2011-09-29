#!/usr/bin/env ruby

Dir[File.expand_path(File.join(File.dirname(__FILE__),'eraser.rb'))].each {|f| require f}
require 'fileutils'
require 'digest'

filepath = File.join(File.dirname(__FILE__), *%w[media test.mp3])
100.times do |n| #for different combinations of failures
  puts "Starting Run #{n}\n==========\n"
  service = Eraser::Service.new
  service.put filepath

  # 0 - 3 node failures
  rand(4).times { service.live_nodes.sample.fail! }

  service.repair if rand(2) == 0

  reassembled_data = service.read(File.basename(filepath))
  reassembled_hash = Digest::SHA1.hexdigest(reassembled_data)
  original_hash = Digest::SHA1.hexdigest(File.read(filepath))
  raise("FAILURE reading consistent reassembled file") unless reassembled_hash == original_hash 
  puts (reassembled_hash == original_hash ? "SUCCESS" : "FAILURE") + ' reading consistent reassembled file'  
  puts "\n\n"
end
