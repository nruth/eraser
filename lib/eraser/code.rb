module Eraser
  class Code
    def self.node_bitmasks(node_id)
      case node_id
      when 1
        [0b1000, 0b0110]
      when 2
        [0b0100, 0b0011]
      when 3
        [0b0010, 0b1101]
      when 4
        [0b0001, 0b1010]
      when 5
        [0b1100, 0b0101]
      end
    end
    
    def self.fundamental_bitmasks(n)
      (0..n-1).map {|x| 2**x}
    end
  end
end