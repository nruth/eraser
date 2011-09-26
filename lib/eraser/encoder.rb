module Eraser
  class Encoder
    attr_reader :file
    attr_reader :n_pieces
    def initialize(file, n_pieces)
      @file = file
      @n_pieces = n_pieces
    end

    # encodes the file passed to the initialiser
    # writing the recombined (by erasure code) files to disk
    def encode
      fundamental_pieces = Chopper.new(file).split_file_into_n_pieces(n_pieces)
      codes_to_pack = (Eraser::Code.basis_vectors - Eraser::Code.fundamental_bitmasks(4)).uniq
      packed_pieces = codes_to_pack.map do |bitmask|
        encode_pieces_with_bitmask(fundamental_pieces, bitmask)
      end
      all_encoded_pieces = fundamental_pieces + packed_pieces
    end

    def encode_pieces_with_bitmask(pieces, bitmask)
      raise "must have 4 pieces" unless pieces.length == 4
      Piece.content_xor_to_new_file Code.elements_indexed_by_bitmask(pieces, bitmask)
    end
  end
end