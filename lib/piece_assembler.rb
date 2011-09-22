require File.join(File.dirname(__FILE__), 'pieces')
require File.join(File.dirname(__FILE__), 'padding')

class PieceAssembler
  attr_reader :filename
  def initialize(filename)
    @filename = filename
  end

  #final assembly from base pieces, doesn't encode/decode anything
  def build_from_pieces(num_pieces)
    binary = ""
    piece_names = Pieces.piece_names(filename, num_pieces)
    piece_names[0..-2].each {|piece| binary << File.read(piece) }

    last_piece = piece_names.last
    binary << File.read(last_piece, File.stat(last_piece).size - Padding.read_padding_bytes(filename))
    binary
  end

  def self.decode_pieces(pieces, wanted_pieces)
    solutions = []
    self.all_possible_combinations.each do |combination_of_pieces|
      puts "trying #{combination_of_pieces}"
      wanted_pieces.each do |wanted_piece|
        puts "looking for #{wanted_piece}"
        if combination_xors_to_wanted_piece?(pieces, combination_of_pieces, wanted_piece)
          solutions << combination_of_pieces
          break
        end
      end
    end
  end

  def self.all_possible_combinations
    require 'set'
    perms = (1..4).map{|n| [1, 2, 3, 4].permutation(n).to_a}.flatten(1)
    perm_set = Set.new | (perms.map {|p| Set.new | p  })
    perm_set
  end
  
  def self.combination_xors_to_wanted_piece?(pieces, combination_of_pieces, wanted_piece)
    # pieces = [0b1000, 0b0110, 0b0011, 0b0100] etc metadata
    # combination_of_pieces = 0b0110 current test pattern
    # wanted_piece = 0b0001 or whatever for o1 o2 etc

    # if (pieces masked by combination_of_pieces).fold(xor)
    # is a bit sequence in wanted_pieces
    # return true
    
    pieces_to_xor = elements_indexed_by_bitmask(pieces, combination_of_pieces)
    result = pieces_to_xor.reduce(:'^')
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