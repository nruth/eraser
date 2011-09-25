module Eraser
  module Padding
    def self.padding_metafile(filename)
      "#{filename}.end_padding"
    end

    def self.read_padding_bytes(filename)
      ::File.read(padding_metafile(filename)).to_i
    end

    #record the padding so it can be ignored on read/reconstruction
    def self.write_padding_metafile(filename, padding_bytes)
      padding_file = File.appended_filename(filename, 'end_padding')
      ::File.open(padding_file, 'w') {|f| f.print padding_bytes } 
    end

    def self.zero_pad_eof(file, bytes)
      padding = [].fill(0, 0, bytes).pack('c*')
      file.append padding
    end
  end
end