module Eraser
  class Decoder
    attr_reader :pieces

    #pieces - available pieces (Eraser::Piece)
    # - must be of length 4 currently for decoding to succeed
    def initialize(pieces)
      raise "fail, too many pieces #{pieces.join(', ')}" unless pieces.length == 4
      @pieces = pieces
    end

    # decodes wanted pieces & writes to disk
    def decode_to_files(wanted_pieces)
      solutions = self.solutions(wanted_pieces.map(&:bitmask))
      solutions.map do |solution|
        pieces_selected_by_solution = Code.elements_indexed_by_bitmask(pieces, solution)
        Piece.content_xor_to_new_file(pieces_selected_by_solution)
      end
    end

    #wanted_pieces - pieces to find, e.g. [0b1000, 0b0100, 0b0010, 0b0001]
    # returns an array of bitmasks, one element for each wanted_piece,
    # which indicates which of the available pieces to xor for wanted_piece reconstruction
    def solutions(wanted_pieces_masks)
      solutions = []
      Decoder.all_possible_combinations.each do |combination_bitmask|
        wanted_pieces_masks.delete_if do |wanted_piece_mask|
          if combination_xors_to?(combination_bitmask, wanted_piece_mask)
            solutions << combination_bitmask
            true
          end
        end
      end
      solutions
    end

    # combination_of_pieces = 0b0110 current test pattern
    # wanted_piece = 0b0001 or whatever for o1 o2 etc  
    def combination_xors_to?(combination_bitmask, wanted_piece_mask)
      pieces_to_xor = Code.elements_indexed_by_bitmask(pieces, combination_bitmask)
      Piece.bitmask_xor(pieces_to_xor) == wanted_piece_mask
    end

    #final assembly from base pieces, doesn't encode/decode anything
    def self.reassemble_original_file(filename, num_pieces)
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