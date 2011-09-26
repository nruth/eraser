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
      @nodes = Node.spawn_nodes(5)
      @nodes.each do |node|
        bitmasks = Eraser::Code.basis_vectors_for_node(node.id)
        nodes_pieces = pieces.select do |p|
          bitmasks.include?(p.bitmask)
        end
        node.copy_pieces(nodes_pieces)
      end
      pieces.each(&:destroy)
    end

    def request_pieces(node, filename)
      pieces = []
      node.pieces(filename).each do |sent_piece|
        new_piece = Piece.new(filename, sent_piece.bitmask)
        new_piece.overwrite(sent_piece.content)
        pieces << new_piece
      end
    end

    def read(filename)
      original_pieces = Eraser::Code.fundamental_bitmasks(num_pieces).map do |code| 
        Eraser::Piece.new(filename, code)
      end
      decode_to_files(original_pieces, pieces_to_decode_with(filename))
      Eraser::Decoder.reassemble_original_file(filename, num_pieces)
    end

    def live_nodes
      @nodes.select(&:is_alive?)
    end

    def pieces_to_decode_with(filename)
      retrieval_nodes = live_nodes[0..1]
      puts "using nodes #{retrieval_nodes.join(', ')} for data retrieval"
      retrieval_nodes.map do |node|
        request_pieces(node, filename)
      end.flatten
    end

    def decode_to_files(wanted_pieces, pieces_to_decode_with)
      decoder = Eraser::Decoder.new(pieces_to_decode_with)
      decoder.decode_to_files wanted_pieces
    end

    # finds failed nodes and regenerates them using the other nodes' stored data
    def repair
      @nodes.reject(&:is_alive?).each do |dead_node|
        puts "repairing #{dead_node}"
        pieces_to_recover = dead_node.pieces.map do |lost_piece|
          Piece.new(lost_piece.original_filename, lost_piece.bitmask)
        end
        puts "repairing #{pieces_to_recover.join(', ')}"
        #TODO: filename should be looped over for the dead node
        filename = pieces_to_recover.first.original_filename
        new_pieces = decode_to_files(pieces_to_recover, pieces_to_decode_with(filename))
        dead_node.copy_pieces(new_pieces)
      end
    end
  end
end
