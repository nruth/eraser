require 'fileutils'

module Eraser
  class Piece
    attr_accessor :original_filename
    attr_accessor :bitmask
    def initialize(original_filename, bitmask, storage_path=nil)
      self.original_filename = ::File.basename(original_filename)
      self.bitmask = bitmask
      @storage_path = storage_path
    end

    def to_s
      filename
    end

    def filename
      filename = File.bitmask_appended_filename(original_filename, bitmask)
      @storage_path ? ::File.join(@storage_path, filename) : filename
    end

    def ^(piece)
      bitmask | piece.bitmask
    end

    # pieces = [Eraser::Piece] array to or
    def self.bitmask_xor(pieces)
      codes = pieces.map(&:bitmask).reduce(:'^')
    end

    def self.content_xor_to_new_file(pieces)
      if pieces.length == 1
        pieces.first
      else
        filename = pieces.first.original_filename
        new_bitmask = bitmask_xor(pieces)
        new_piece = Piece.new filename, new_bitmask
        new_piece.reset_content!
        io_streams = pieces.map(&:open_file)
        data = io_streams.map(&:bytes).map(&:to_a)
        data = data.pop.zip(*data).map {|m| m.reduce(:'^')}
        new_piece.append data.pack('c*')
        new_piece
      end
    end

    def open_file
      ::File.open(filename,"rb")
    end

    def overwrite(content)
      ::FileUtils.mkpath(@storage_path) if @storage_path && !::File.exist?(@storage_path)
      ::File.open(filename, 'wb') {|f| f.print content}
      self
    end

    def append(content)
      ::FileUtils.mkpath(@storage_path) if @storage_path && !::File.exist?(@storage_path)
      ::File.open(filename, 'ab') {|f| f.print content}
      self
    end

    def content
      ::File.open(filename,"rb") {|io| io.read}
    end
    
    def reset_content!
      ::FileUtils.mkpath(@storage_path) if @storage_path && !::File.exist?(@storage_path)
      ::File.open(filename, 'w') do
        #truncate file
      end
    end
    
    def destroy
      ::File.delete(filename) if ::File.exists?(filename)
    end
  end
end