module Eraser
  class Piece
    attr_accessor :original_filename
    attr_accessor :bitmask
    def initialize(original_filename, bitmask)
      self.original_filename = ::File.basename(original_filename)
      self.bitmask = bitmask
    end

    def to_s
      filename
    end

    def filename
      File.bitmask_appended_filename(original_filename, bitmask)
    end

    def ^(piece)
      bitmask ^ piece.bitmask
    end

    def self.bitmask_xor(pieces)
      pieces.map(&:bitmask).reduce(:'^')
    end

    def self.content_xor_to_new_file(pieces)
      filename = pieces.first.original_filename
      new_piece = Piece.new filename, bitmask_xor(pieces)
      new_piece.reset_content!
      puts "xoring #{pieces.join(',')} into #{new_piece.filename}"
      io_streams = pieces.map(&:open_file)
      data = io_streams.map(&:bytes).map(&:to_a)
      data = data.pop.zip(*data).map {|m| m.reduce(:'^')}
      new_piece.append data.pack('c*')
      puts "finished #{new_piece.filename}"
      new_piece
    end

    def open_file
      ::File.open(filename,"rb")
    end

    def overwrite(content)
      ::File.open(filename, 'wb') {|f| f.print content}
      self
    end

    def append(content)
      ::File.open(filename, 'ab') {|f| f.print content}
      self
    end

    def content
      ::File.open(filename,"rb") {|io| io.read}
    end
    
    def reset_content!
      ::File.open(filename, 'w') do
        #truncate file
      end
    end
  end
end