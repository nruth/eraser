# require File.join(File.dirname(__FILE__), 'pieces')
# require File.join(File.dirname(__FILE__), 'padding')
# require File.join(File.dirname(__FILE__), 'piece')

module Eraser
  class Chopper
    attr_reader :input_file
    #input_file of type Eraser::File
    def initialize(input_file)
      @input_file = input_file
    end

    # Partitions the data into n new files of equal length, padding the final file with zeros
    # and recording the number of 0s added in an accompanying metafile
    # the original file is not modified
    def split_file_into_n_pieces(num_pieces)
      padding = eof_padding_bytes(num_pieces)
      padded_length = input_file.bytes_in_file + padding
      bytes_per_piece = padded_length / num_pieces
      pieces = create_pieces(num_pieces, bytes_per_piece)
      if padding > 0
        Padding.zero_pad_eof(pieces.last, padding)
        Padding.write_padding_metafile(input_file.name, padding)
      end
    end

    private
    def create_pieces(num_pieces, bytes_per_piece)
      (1..num_pieces).map do |bitmask|
        data = input_file.read(bytes_per_piece)
        create_piece(bitmask, input_file, data)
      end
    end
    
    def create_piece(bitmask, input_stream, data)
      Piece.new(input_file.name, bitmask).overwrite(data)
    end
    
    #pad file byte-length to be evenly divisible
    def eof_padding_bytes(num_pieces)
      bytes_in_file = input_file.bytes_in_file
      leftover_bytes = bytes_in_file % num_pieces
      padding_bytes = (num_pieces - leftover_bytes) % num_pieces
    end
  end
end