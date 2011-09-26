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
      code = Eraser::Code.new
      codes_to_pack = (code.basis_vectors - Code.fundamental_bitmasks(4)).uniq
      codes_to_pack.each do |bitmask|
        encode_pieces_with_bitmask(fundamental_pieces, bitmask)
      end
    end

    def encode_pieces_with_bitmask(pieces, bitmask)
      Piece.content_xor_to_new_file Code.elements_indexed_by_bitmask(pieces, bitmask)
    end
  end
end