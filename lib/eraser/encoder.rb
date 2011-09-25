module Eraser
  class Encoder
    attr_reader :file
    def initialize(file)
      @file = file
    end

    N_PIECES = 4
    def encode
      Chopper.split_file_into_n_pieces file.path
    end
  end
end