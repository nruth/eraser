module Eraser
  class Service
    def num_pieces
      4
    end

    def num_nodes
      5
    end

    def put(file)
      input_file = Eraser::File.new ::File.expand_path(file)
      encoder = Eraser::Encoder.new(input_file, num_pieces)
      pieces = encoder.encode
      distribute_pieces(pieces)
    end

    def distribute_pieces(pieces)
      nodes = Node.spawn_nodes(5)
      nodes.each do |node|
        bitmasks = Eraser::Code.basis_vectors_for_node(node.id)
        nodes_pieces = pieces.select do |p|
          bitmasks.include?(p.bitmask)
        end
        node.copy_pieces(nodes_pieces)
      end
      pieces.each(&:destroy)
    end

    def read(filename)

    end
  end
end
