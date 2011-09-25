module Eraser
  module Pieces
    def self.piece_names(filename, num_pieces)
      (1..num_pieces).map {|n| "#{filename}.o#{n}"}
    end
  end
end