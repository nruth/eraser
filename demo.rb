#!/usr/bin/env ruby

require 'eraser'
require 'fileutils'
require 'digest'

num_pieces = 4

input_file = Eraser::File.new File.join(File.dirname(__FILE__), *%w[media test.jpg])
encoder = Eraser::Encoder.new(input_file, num_pieces)
pieces = encoder.encode

#use nodes 1 and 2 to rebuild something on node 4
#pick a file to delete & store a hash of its contents
removed_filename = 'test.jpg.0001' 
original_hash = Digest::SHA1.hexdigest(File.read(removed_filename))

#delete it and remove from available pieces
`rm #{removed_filename}`
available_pieces = pieces.reject {|p| p.bitmask == 0b0001}
raise "fail" if available_pieces == pieces
code = Eraser::Code.new

pieces_to_decode_with = Eraser::Code.new.basis_vectors_for_node(1) 
pieces_to_decode_with += Eraser::Code.new.basis_vectors_for_node(2)
pieces_to_decode_with = pieces_to_decode_with.map {|code| Eraser::Piece.new(input_file.name, code)}

decoder = Eraser::Decoder.new(pieces_to_decode_with)
wanted_piece = Eraser::Piece.new(input_file.name, 0b0001)

# Decode and check contents are as they were before deleting
decoder.decode [wanted_piece]
reassembled_hash = Digest::SHA1.hexdigest(wanted_piece.content)
puts original_hash == reassembled_hash ? "SUCCESS" : "FAILURE"


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
File.open(input_file.name, 'w') {|f| f.print reassembled}

reassembled_hash = Digest::SHA1.hexdigest(reassembled)
original_hash = Digest::SHA1.hexdigest(File.read(input_file.path))
puts reassembled_hash
puts original_hash
puts original_hash == reassembled_hash ? "SUCCESS" : "FAILURE"