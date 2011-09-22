require File.join(File.dirname(__FILE__), 'pieces')
require File.join(File.dirname(__FILE__), 'padding')

class PieceAssembler
  attr_reader :pieces

  #pieces - available pieces' bitsequences, e.g. [0b1000, 0b0110, 0b0011, 0b0100]
  def initialize(pieces)
    @pieces = pieces
  end

  #wanted_pieces - pieces to find, e.g. [0b1000, 0b0100, 0b0010, 0b0001]
  def decode_pieces(wanted_pieces)
    solutions = []
    self.class.all_possible_combinations.each do |combination|
      wanted_pieces.each do |wanted_piece|
        if combination_xors_to_wanted_piece?(combination, wanted_piece)
          solutions << combination
          break
        end
      end
    end
    solutions
  end

  # combination_of_pieces = 0b0110 current test pattern
  # wanted_piece = 0b0001 or whatever for o1 o2 etc  
  def combination_xors_to_wanted_piece?(combination_of_pieces, wanted_piece)
    pieces_to_xor = self.class.elements_indexed_by_bitmask(pieces, combination_of_pieces)
    pieces_to_xor.reduce(:'^') == wanted_piece
  end

  #final assembly from base pieces, doesn't encode/decode anything
  def self.build_from_pieces(filename, num_pieces)
    binary = ""
    piece_names = Pieces.piece_names(filename, num_pieces)
    piece_names[0..-2].each {|piece| binary << File.read(piece) }

    last_piece = piece_names.last
    binary << File.read(last_piece, File.stat(last_piece).size - Padding.read_padding_bytes(filename))
    binary
  end

  def self.all_possible_combinations
    (1..15).to_a
  end

  def self.elements_indexed_by_bitmask(array, bitmask)
    raise "only supports length 4 arrays" unless array.length == 4 
    result = []
    [0b0001, 0b0010, 0b0100, 0b1000].reverse.each_with_index do |pieces_index_mask, i|
      if (bitmask & pieces_index_mask) != 0
        result << array[i]
      end
    end
    result
  end
end