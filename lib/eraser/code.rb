module Eraser
  module Code
    def self.code
      {
        1 =>  [0b1000, 0b0110],
        2 =>  [0b0100, 0b0011],
        3 =>  [0b0010, 0b1101],
        4 =>  [0b0001, 0b1010],
        5 =>  [0b1100, 0b0101]
      }
    end

    def self.basis_vectors
      code.values.flatten
    end

    def self.basis_vectors_for_node(node_id)
      code[node_id]
    end

    def self.fundamental_bitmasks(n)
      (0..n-1).map {|x| 2**x}
    end

    def self.elements_indexed_by_bitmask(array, bitmask)
      raise "only supports length 4 arrays, received array: #{array.join(', ')}, bitmask: #{format('%04b', bitmask)}" unless array.length == 4 
      result = []
      fundamental_bitmasks(4).each_with_index do |pieces_index_mask, i|
        result << array[i] if (bitmask & pieces_index_mask) != 0
      end
      result
    end
  end
end