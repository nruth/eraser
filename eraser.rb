#!/usr/bin/env ruby
require 'lib/file_split'

mp3 = File.join(File.dirname(__FILE__), *%w[media test.mp3])
FileSplit.new(mp3).split_file_into_n_pieces(2)
