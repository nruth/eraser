module Eraser
  class Decoder
    def piece_groups
      @piece_groups.dup
    end

    #piece_groups - groups of available pieces (Eraser::Piece)
    # - e.g. [[o1,o1o2], [o3o4,o3]]
    def initialize(piece_groups)
      raise "array expected" unless piece_groups.is_a?(Array)
      first_element = piece_groups.first
      raise "nested array expected" unless first_element == nil || first_element.is_a?(Array)
      @piece_groups = piece_groups
    end

    # decodes wanted pieces & writes to disk
    def decode_to_files(wanted_pieces)
      solution = solve_with_three_groups(wanted_pieces) || solve_with_two_groups(wanted_pieces)
      solution.map {|pieces| Piece.content_xor_to_new_file(pieces)}
    end

    def solve_with_three_groups(wanted_pieces)
      if piece_groups.length < 3
        puts "too few nodes for 3-node assembly"
        return false
      end
      wanted_masks = wanted_pieces.map(&:bitmask)
      piece_groups.permutation(3).each do |current_nodes|
        n = current_nodes.dup; n.shift.product(*n).each do |pieces|
          piece_masks = pieces.map(&:bitmask)
          solutions = self.solutions_from_three(wanted_masks, piece_masks)
          if solutions.values.length == wanted_pieces.length
            solvant = solutions.keys.map {|wanted| Code.elements_indexed_by_bitmask(pieces, solutions[wanted].first)}
            puts "Solved with 3 nodes, #{solvant.length} pieces: #{solvant.map{|p| "[#{p.join(', ')}]"}} (solutions #{printf_bitmasks_hash(solutions)})"
            return solvant
          end
        end
      end
      false
    end

    def solve_with_two_groups(wanted_pieces)
      pieces = (piece_groups.first + piece_groups.last).flatten
      solutions = self.solutions(wanted_pieces.map(&:bitmask), pieces.map(&:bitmask))
      pieces = solutions.map {|mask| Code.elements_indexed_by_bitmask(pieces, mask)}
      puts "Solved with 2 nodes, #{pieces.length} combinations: #{pieces.map{|p| "[#{p.join(', ')}]"}}"
      pieces
    end

    #wanted_pieces - pieces to find, e.g. [0b1000, 0b0100, 0b0010, 0b0001]
    # returns an array of bitmasks, one element for each wanted_piece,
    # which indicates which of the available pieces to xor for wanted_piece reconstruction
    def solutions(wanted_pieces_masks, available_piece_masks)
      solutions = []
      Decoder.all_possible_combinations(4).each do |combination_bitmask|
        wanted_pieces_masks.delete_if do |wanted_piece_mask|
          if combination_xors_to?(combination_bitmask, wanted_piece_mask, available_piece_masks)
            solutions << combination_bitmask
            true
          end
        end
      end
      solutions
    end

    def solutions_from_three(wanted_pieces_masks, available_piece_masks)
      solutions = Hash.new([])
      Decoder.all_possible_combinations(3).each do |combination_bitmask|
        mutable_wanted_pieces_masks = wanted_pieces_masks.dup
        mutable_wanted_pieces_masks.delete_if do |wanted_piece_mask|
          if combination_xors_to?(combination_bitmask, wanted_piece_mask, available_piece_masks)
            solutions[wanted_piece_mask] = solutions[wanted_piece_mask] + [combination_bitmask]
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

    # all nonzero bitmasks from 0001 up to (2^elements - 1)
    def self.all_possible_combinations(elements)
      x = (2**elements) - 1
      (1..x).to_a
    end

    def printf_bitmasks_hash(hsh)
      hsh.to_a.map {|b|"#{printf_bitmask(b[0])} => #{printf_bitmasks(b[1])}"}.join(', ')
    end

    def printf_bitmasks(arry)
      "[#{arry.map {|b|printf_bitmask(b)}.join(', ')}]"
    end

    def printf_bitmask(bitmask)
      format('%04b',bitmask)
    end
  end
end