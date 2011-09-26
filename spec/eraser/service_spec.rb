require File.join(File.dirname(__FILE__), *%w[.. .. eraser])
require 'digest'

describe Eraser::Service do
  let(:service) {Eraser::Service.new}
  describe "put(filepath_string)" do
    let(:filepath) {mock}
    let(:encoder) {mock}
    let(:wrapped_input_file) {mock}
    before(:each) do
      Eraser::File.stub(:new).and_return wrapped_input_file
      Eraser::Encoder.stub(:new).and_return encoder
      service.stub(:distribute_pieces)
      encoder.stub(:encode)
    end

    it "normalises the path & wraps the file in an Eraser::File" do
      File.should_receive(:expand_path).with(filepath).and_return filepath
      Eraser::File.should_receive(:new).with(filepath).and_return wrapped_input_file
      service.put(filepath)
    end

    it "encodes the file in 4 pieces" do
      Eraser::Encoder.should_receive(:new).with(wrapped_input_file, 4)
      encoder.should_receive(:encode)
      service.put(filepath)
    end

    it "distributes the pieces across 5 nodes" do
      pieces = mock
      encoder.should_receive(:encode).and_return pieces
      service.should_receive(:distribute_pieces).with(pieces)
      service.put(filepath)
    end
  end

  describe "distribute_pieces(pieces)" do

    let(:node) {mock}
    let(:nodes) {[node]}
    let(:bitmask) {0b0010}
    let(:piece) {mock(:bitmask => bitmask)}
    let(:pieces) {[piece]}
    before(:each) do
      Eraser::Node.stub(:spawn_nodes).and_return nodes
      Eraser::Code.stub(:basis_vectors_for_node).and_return [bitmask]
      piece.stub(:destroy)
      node.stub(:copy_pieces)
    end

    it "spawns 5 nodes" do
      Eraser::Node.should_receive(:spawn_nodes).with(5).and_return nodes
      service.distribute_pieces(pieces)
    end

    it "sends the basis vector decided pieces to each node" do
      node_id = mock
      node.should_receive(:id).and_return node_id
      Eraser::Code.should_receive(:basis_vectors_for_node).with(node_id).and_return [bitmask]
      node.should_receive(:copy_pieces).with([piece])
      service.distribute_pieces(pieces)
    end

    it "deletes local pieces generated during encoding" do
      piece.should_receive(:destroy)
      service.distribute_pieces(pieces)
    end
  end

  describe "read(filename)" do
    around(:each) do |example|
      require 'fileutils'
      begin
        FileUtils.mkdir 'tmp'
        FileUtils.cd 'tmp' do
          example.run
        end
      ensure
        FileUtils.rm_rf 'tmp'
      end
    end


    let(:filepath) {File.join(File.dirname(__FILE__), *%w[.. .. media test.jpg])}
    it "takes a filename and returns the file contents" do
      service = Eraser::Service.new
      service.put filepath
      reassembled_data = service.read('test.jpg')
      reassembled_hash = Digest::SHA1.hexdigest(reassembled_data)
      original_hash = Digest::SHA1.hexdigest(File.read(filepath))
      reassembled_hash.should == original_hash
    end

    describe "when some nodes have failed" do
      it "takes a filename and returns the file contents" do
        5.times do #for different combinations of failures
          service = Eraser::Service.new
          service.put filepath
          (1..3).to_a.choice.times do #for different numbers of failures
            service.live_nodes.choice.fail!
          end

          reassembled_data = service.read('test.jpg')
          reassembled_hash = Digest::SHA1.hexdigest(reassembled_data)
          original_hash = Digest::SHA1.hexdigest(File.read(filepath))
          reassembled_hash.should == original_hash
        end
      end
    end
  end

  describe "repair_nodes" do
    let(:filepath) {File.join(File.dirname(__FILE__), *%w[.. .. media test.jpg])}
    let(:filename) {File.basename(filepath)}
    context "when 1 node has failed (and its pieces are lost)" do
      it "reconstructs the missing node and its pieces" do
        service = Eraser::Service.new
        service.put filepath
        failed = service.live_nodes.choice
        stored_piece_path = failed.pieces(filename).first.filename
        File.should exist(stored_piece_path)
        original_hash = Digest::SHA1.hexdigest(File.read(stored_piece_path))

        failed.fail!

        File.should_not exist(stored_piece_path)

        service.repair
        File.should exist(stored_piece_path)
        reassembled_hash = Digest::SHA1.hexdigest(File.read(stored_piece_path))

        reassembled_hash.should == original_hash
      end
    end
  end
end
