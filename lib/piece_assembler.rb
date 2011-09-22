require File.join(File.dirname(__FILE__), 'pieces')
require File.join(File.dirname(__FILE__), 'padding')

class PieceAssembler
  attr_reader :filename
  def initialize(filename)
    @filename = filename
  end

  def build_from_pieces(num_pieces)
    binary = ""
    piece_names = Pieces.piece_names(filename, num_pieces)
    piece_names[0..-2].each {|piece| binary << File.read(piece) }

    last_piece = piece_names.last
    binary << File.read(last_piece, File.stat(last_piece).size - Padding.read_padding_bytes(filename))
    binary
  end
end