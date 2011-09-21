module FileSplit
  extend(self)

  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def split_file_into_n_pieces(filepath, num_pieces)
    input_file = File.new filepath
    input_filename = File.basename filepath
    bytes_in_file = input_file.stat.size

    padded_input_byte_length = bytes_in_file
    padding_bytes = 0
    leftover_bytes = bytes_in_file % num_pieces
    unless leftover_bytes == 0
      padding_bytes = num_pieces - leftover_bytes
      padded_input_byte_length = bytes_in_file + padding_bytes
      record_padding(input_filename, padding_bytes)
    end

    bytes_per_piece = padded_input_byte_length /num_pieces
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
  def record_padding(input_filename, padding_bytes)
    File.open("#{input_filename}.end_padding", 'w') {|f| f.print padding_bytes } 
  end
end