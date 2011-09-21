require 'pieces'
require 'padding'

class FileSplit
  attr_reader :input_filepath
  def initialize(input_filepath)
    @input_filepath = input_filepath
  end

  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def split_file_into_n_pieces(num_pieces)
    eof_padding_bytes = Padding.determine_padding_bytes(num_pieces, bytes_in_file)

    bytes_per_piece = (bytes_in_file + eof_padding_bytes) / num_pieces
    piece_filenames = Pieces.piece_names(input_filename, num_pieces)
    piece_filenames.each do |piece_filename|
      create_piece(piece_filename, input_file, bytes_per_piece)
    end

    if eof_padding_bytes > 0
      zero_pad_eof(piece_filenames.last, eof_padding_bytes)
      Padding.write_padding_metafile(input_filename, eof_padding_bytes) 
    end
  end

  private
  def zero_pad_eof(filename, eof_padding_bytes)
    File.open(filename, 'a') {|f| f.print(((1..eof_padding_bytes).map {0}).pack('c*'))}
  end

  def create_piece(filename, input_stream, piece_size)
    File.open filename, 'w' do |piece_file|
      piece_file.print input_stream.read(piece_size)
    end
  end

  def input_filename
    File.basename input_filepath
  end

  def input_file
    @_input_file ||= File.open(input_filepath)
  end

  def bytes_in_file
    input_file.stat.size
  end
end