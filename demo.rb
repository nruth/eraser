#!/usr/bin/env ruby

require 'eraser'
require 'fileutils'
require 'digest'

filepath = File.join(File.dirname(__FILE__), *%w[media test.mp3])
100.times do |n| #for different combinations of failures
  puts "Starting Run #{n}\n==========\n"
  service = Eraser::Service.new
  service.put filepath
  (1..3).to_a.choice.times do #for different numbers of failures
     service.live_nodes.choice.fail!
   end

  service.repair if rand(2) == 0

  reassembled_data = service.read(File.basename(filepath))
  reassembled_hash = Digest::SHA1.hexdigest(reassembled_data)
  original_hash = Digest::SHA1.hexdigest(File.read(filepath))
  raise("FAILURE reading consistent reassembled file") unless reassembled_hash == original_hash 
  puts (reassembled_hash == original_hash ? "SUCCESS" : "FAILURE") + ' reading consistent reassembled file'  
  puts "\n\n"
end
