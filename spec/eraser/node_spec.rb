require File.join(File.dirname(__FILE__), *%w[.. .. eraser])
describe Eraser::Node do
  let(:node_id) {mock}
  let(:node) {Eraser::Node.new(node_id)}
  subject {node}

  describe "copy_piece" do
    it "makes a new piece with the contents of the given piece" do
      piece = mock
      content, filename, bitmask = mock, mock, mock
      piece.stub(:content).and_return content
      piece.stub(:original_filename).and_return filename
      piece.stub(:bitmask).and_return bitmask
      node.stub(:storage_path).and_return storage_path = mock
      Eraser::Piece.should_receive(:new).with(filename, bitmask, storage_path).and_return new_piece = mock
      new_piece.should_receive(:overwrite).with(content)
      node.copy_piece piece
    end
  end
  
  describe "copy_pieces(pieces)" do
    it "copies the pieces" do
      m1, m2 = mock, mock
      subject.should_receive(:copy_piece).with(m1).ordered
      subject.should_receive(:copy_piece).with(m2).ordered
      subject.copy_pieces [m1, m2]
    end
  end
end
