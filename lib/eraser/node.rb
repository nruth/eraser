module Eraser
  class Node
    attr_reader :id
    attr_reader :root_path
    def initialize(id)
      @id = id
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
    end
    
    def storage_path
      "#{id}"
    end
  end
end