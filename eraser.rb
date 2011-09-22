#!/usr/bin/env ruby
require 'lib/file_split'
require 'lib/piece_assembler'

PIECES = 4

mp3 = File.join(File.dirname(__FILE__), *%w[media test.mp3])
FileSplit.new(mp3).split_file_into_n_pieces(PIECES)

File.open('test.mp3', 'w') do |f|
  f << PieceAssembler.new('test.mp3').build_from_pieces(PIECES)
end