module FileSplit
  extend(self)

  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def split_file_into_n_pieces(filepath, num_pieces)
    input_file = File.new filepath
    input_filename = File.basename filepath
    bytes_in_file = input_file.stat.size

    # we know how many pieces we want
    # so let's find how many bytes we will share between them
    # such that they have an equal byte-length
    bytes_per_piece = (bytes_in_file/num_pieces)

    # When the file's byte-length is not integer divisible by n pieces
    # some bytes are left over
    # if we pad the missing bytes we can increase each blocks's share by 1
    leftover_bytes = bytes_in_file % num_pieces
    eof_padding_bytes = 0
    if leftover_bytes > 0
      bytes_per_piece += 1
      eof_padding_bytes = bytes_per_piece - leftover_bytes
    end

    piece_filenames = (1..num_pieces).map {|n| "#{input_filename}.o#{n}"}
    piece_filenames.each do |piece_filename|
      create_piece(piece_filename, input_file, bytes_per_piece)
    end

    unless eof_padding_bytes == 0
      #record the padding so it can be ignored on read/reconstruction
      File.open("#{input_filename}.end_padding", 'w') {|f| f.print eof_padding_bytes}

      #pad the file TODO: spec then add
      # File.open(piece_filename.last, 'a') {|f| f.print padding_bytes}
    end
  end

  private
  def create_piece(filename, input_stream, piece_size)
    File.open filename, 'w' do |piece_file|
      piece_file.print input_stream.read(piece_size)
    end
  end
end