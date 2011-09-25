module Eraser
  class Piece
    attr_accessor :original_filename
    attr_accessor :bitmask
    def initialize(original_filename, bitmask)
      self.original_filename = ::File.basename(original_filename)
      self.bitmask = bitmask
    end

    def filename
      File.bitmask_appended_filename(original_filename, bitmask)
    end

    def ^(piece)
      self.bitmask ^ piece.bitmask
    end

    def overwrite(content)
      ::File.open(filename, 'w') {|f| f.print content}
      self
    end

    def append(content)
      ::File.open(filename, 'a') {|f| f.print content}
      self
    end

    def content
      ::File.read(filename)
    end
  end
end