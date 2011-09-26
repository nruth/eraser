#!/usr/bin/env ruby

require 'eraser'

input_file = Eraser::File.new File.join(File.dirname(__FILE__), *%w[media test.mp3])
encoder = Eraser::Encoder.new(input_file, 4)
encoder.encode