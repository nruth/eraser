module FileSplit
  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def self.split_file_into_n_pieces(filepath, num_pieces)
    input_file = File.new filepath
    bytes_in_file = input_file.stat.size

    num_pieces.times do |n|
      #open this piece's output file for writing
      #format is original_filename.o[0..num_pieces-1]
      input_file_name = File.basename(filepath)
      File.open "#{input_file_name}.o#{n}", 'w' do |piece_file|
        piece_file.print input_file.read(bytes_in_file/num_pieces)
      end
    end
  end
end