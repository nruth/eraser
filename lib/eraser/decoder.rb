module Eraser
  class Decoder
    attr_reader :pieces

    #pieces - available pieces' bitsequences, e.g. [0b1000, 0b0110, 0b0011, 0b0100]
    def initialize(pieces)
      @pieces = pieces
    end

    #wanted_pieces - pieces to find, e.g. [0b1000, 0b0100, 0b0010, 0b0001]
    def decode_pieces(wanted_pieces)
      solutions = []
      Decoder.all_possible_combinations.each do |combination|
        wanted_pieces.delete_if do |wanted_piece|
          if combination_xors_to_wanted_piece?(combination, wanted_piece)
            solutions << combination
            true
          end
        end
      end
      solutions
    end

    # combination_of_pieces = 0b0110 current test pattern
    # wanted_piece = 0b0001 or whatever for o1 o2 etc  
    def combination_xors_to_wanted_piece?(combination_of_pieces, wanted_piece)
      pieces_to_xor = Code.elements_indexed_by_bitmask(pieces, combination_of_pieces)
      pieces_to_xor.reduce(:'^') == wanted_piece
    end

    #final assembly from base pieces, doesn't encode/decode anything
    def self.build_from_pieces(filename, num_pieces)
      binary = ""
      piece_names = Code.fundamental_bitmasks(num_pieces).map{|n| File.bitmask_appended_filename(filename, n)}
      piece_names[0..-2].each {|piece| binary << ::File.read(piece) }

      last_piece = piece_names.last
      binary << ::File.read(last_piece, ::File.stat(last_piece).size - Eraser::Padding.read_padding_bytes(filename))
      binary
    end

    def self.all_possible_combinations
      (1..15).to_a
    end
  end
end