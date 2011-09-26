#!/usr/bin/env ruby

require 'eraser'
require 'fileutils'
require 'digest'

num_pieces = 4

input_file = Eraser::File.new File.join(File.dirname(__FILE__), *%w[media test.mp3])
encoder = Eraser::Encoder.new(input_file, num_pieces)
pieces = encoder.encode


# removed = pieces.pop
# original_hash = Digest::SHA1.hexdigest(File.read(removed.filename))
# puts "deleting #{removed}"
# FileUtils.rm removed.filename
# code = Eraser::Code.new
# available_pieces = code.basis_vectors_for_node(2) + code.basis_vectors_for_node(4)
# available_pieces = available_pieces.map {|code| Eraser::Piece.new input_file.name, code}
# decoder = Eraser::Decoder.new(available_pieces)
# decoded_pieces = decoder.decode([Eraser::Piece.new(input_file.name, removed.bitmask)])
# reassembled_hash = Digest::SHA1.hexdigest(decoded_pieces.first.content)

reassembled = Eraser::Decoder.build_from_pieces(input_file.name, num_pieces)
File.open('test.mp3', 'w') {|f| f.print reassembled}

reassembled_hash = Digest::SHA1.hexdigest(reassembled)
original_hash = Digest::SHA1.hexdigest(File.read(input_file.path))
puts reassembled_hash
puts original_hash
puts original_hash == reassembled_hash ? "SUCCESS" : "FAILURE"