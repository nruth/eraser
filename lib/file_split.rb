module FileSplit
  extend(self)

  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def split_file_into_n_pieces(filepath, num_pieces)
    input_file = File.new filepath
    bytes_in_file = input_file.stat.size

    num_pieces.times do |n| 
      create_piece("#{File.basename(filepath)}.o#{n}", input_file, bytes_in_file/num_pieces)
    end
  end

  private
  def create_piece(filename, input_stream, piece_size)
    File.open filename, 'w' do |piece_file|
      piece_file.print input_stream.read(piece_size)
    end
  end
end