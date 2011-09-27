module Eraser
  class Decoder
    attr_reader :piece_groups

    #piece_groups - groups of available pieces (Eraser::Piece)
    # - e.g. [[o1,o1o2], [o3o4,o3]]
    def initialize(piece_groups)
      @piece_groups = piece_groups
    end

    # decodes wanted pieces & writes to disk
    def decode_to_files(wanted_pieces)
      pieces = piece_groups.flatten
      solutions = self.solutions(wanted_pieces.map(&:bitmask), pieces.map(&:bitmask))
      solutions.map do |solution|
        pieces_selected_by_solution = Code.elements_indexed_by_bitmask(pieces, solution)
        Piece.content_xor_to_new_file(pieces_selected_by_solution)
      end
    end

    #wanted_pieces - pieces to find, e.g. [0b1000, 0b0100, 0b0010, 0b0001]
    # returns an array of bitmasks, one element for each wanted_piece,
    # which indicates which of the available pieces to xor for wanted_piece reconstruction
    def solutions(wanted_pieces_masks, available_piece_masks)
      solutions = []
      Decoder.all_possible_combinations.each do |combination_bitmask|
        wanted_pieces_masks.delete_if do |wanted_piece_mask|
          if combination_xors_to?(combination_bitmask, wanted_piece_mask, available_piece_masks)
            solutions << combination_bitmask
            true
          end
        end
      end
      solutions
    end

    # combination_of_pieces = 0b0110 current test pattern
    # wanted_piece = 0b0001 or whatever for o1 o2 etc  
    # pieces = pieces which will be assembled in some combination to form wanted pieces
    def combination_xors_to?(combination_bitmask, wanted_piece_mask, available_piece_masks)
      pieces_to_xor = Code.elements_indexed_by_bitmask(available_piece_masks, combination_bitmask)
      pieces_to_xor.reduce(:'^') == wanted_piece_mask
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