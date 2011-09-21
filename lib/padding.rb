module Padding
  def self.padding_metafile(filename)
    "#{filename}.end_padding"
  end

  def self.read_padding_bytes(filename)
    File.read(padding_metafile(filename)).to_i
  end

  #record the padding so it can be ignored on read/reconstruction
  def self.write_padding_metafile(filename, padding_bytes)
    File.open("#{filename}.end_padding", 'w') {|f| f.print padding_bytes } 
  end

  #pad file byte-length to be evenly divisible
  def self.determine_padding_bytes(num_pieces, bytes_in_file)
    leftover_bytes = bytes_in_file % num_pieces
    padding_bytes = num_pieces - leftover_bytes
  end
end