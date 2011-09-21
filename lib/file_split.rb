module FileSplit
  #given a File instance it will partition the data into n new pieces
  #the original file is not modified
  def self.split_file_into_n_pieces(file)
    bytes_in_file = file.stat.size
  end
end