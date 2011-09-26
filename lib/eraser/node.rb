module Eraser
  class Node
    attr_reader :id
    attr_reader :root_path
    def initialize(id)
      @id = id
      @pieces = []
    end

    def self.spawn_nodes(n)
      (1..n).map {|id| Node.new(id)}
    end

    def copy_pieces(pieces)
      pieces.each{|p| copy_piece(p)}
    end

    def copy_piece(piece)
      p = Piece.new(piece.original_filename, piece.bitmask, storage_path)
      p.overwrite(piece.content)
      @pieces << p
    end

    def storage_path
      "#{id}"
    end

    def pieces(filename=nil)
      @pieces
    end

    def is_alive?
      ::File.exists? storage_path
    end
    
    def fail!
      require 'fileutils'
      FileUtils.rm_rf storage_path
      puts "Node #{id}: BANG"
    end
    
    def to_s
      "Node #{id}"
    end
  end
end