class FileSplit
  attr_reader :input_filepath
  def initialize(input_filepath)
    @input_filepath = input_filepath
  end

  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def split_file_into_n_pieces(num_pieces)
    #pad file byte-length to be evenly divisible
    eof_padding_bytes = determine_padding_bytes(num_pieces)
    write_padding_metafile(eof_padding_bytes) if eof_padding_bytes > 0

    bytes_per_piece = (bytes_in_file + eof_padding_bytes) / num_pieces
    piece_filenames = (1..num_pieces).map {|n| "#{input_filename}.o#{n}"}
    piece_filenames.each do |piece_filename|
      create_piece(piece_filename, input_file, bytes_per_piece)
    end

    # unless padding_bytes == 0
    #   #pad the file TODO: spec then add
    #   # File.open(piece_filename.last, 'a') {|f| f.print padding_bytes}
    # end
  end

  private
  def create_piece(filename, input_stream, piece_size)
    File.open filename, 'w' do |piece_file|
      piece_file.print input_stream.read(piece_size)
    end
  end

  #record the padding so it can be ignored on read/reconstruction
  def write_padding_metafile(padding_bytes)
    File.open("#{input_filename}.end_padding", 'w') {|f| f.print padding_bytes } 
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
  
  def determine_padding_bytes(num_pieces)
    leftover_bytes = bytes_in_file % num_pieces
    padding_bytes = num_pieces - leftover_bytes
  end
end