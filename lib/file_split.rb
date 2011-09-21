module FileSplit
  #given a filepath string it will partition the data into n new pieces
  #the original file is not modified
  def self.split_file_into_n_pieces(filepath, num_pieces)
    file = File.new filepath
    bytes_in_file = file.stat.size
    input_file = File.basename(filepath)
    num_pieces.times do |n|
      File.open "#{input_file}.o#{n}", 'w' do |piece_file|
        piece_file.print File.read(filepath, bytes_in_file/3)
      end
    end
  end
end