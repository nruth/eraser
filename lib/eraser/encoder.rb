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
      encoded_pieces = encode_pieces(fundamental_pieces)
      all_encoded_pieces = fundamental_pieces + encoded_pieces
    end

    def encode_pieces_with_bitmask(pieces, bitmask)
      raise "must have #{n_pieces} pieces" unless pieces.length == n_pieces
      pieces_indexed = Code.elements_indexed_by_bitmask(pieces, bitmask)
      Piece.content_xor_to_new_file pieces_indexed
    end

    def encode_pieces(fundamental_pieces)
      encoded_pieces = (Eraser::Code.basis_vectors - Eraser::Code.fundamental_bitmasks(n_pieces)).map do |bitmask|
        encode_pieces_with_bitmask(fundamental_pieces, bitmask)
      end
    end
  end
end