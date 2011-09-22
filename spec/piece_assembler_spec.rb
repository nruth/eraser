require File.join(File.dirname(__FILE__), *%w[.. lib piece_assembler])

describe PieceAssembler do
  describe "decode_pieces(wanted_pieces)" do
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

    it "returns a combination for the requested piece code" do
      pending
      PieceAssembler.decode_pieces([0b1000, 0b0110, 0b0011, 0b0100], [0b1000]).should == [0b1000]
      PieceAssembler.decode_pieces([0b0100]).should == [0b0100]
      PieceAssembler.decode_pieces([0b0010]).should == [0b0101]
      PieceAssembler.decode_pieces([0b0001]).should == [0b0111]
    end
  end
  
  describe "elements_indexed_by_bitmask(array, bitmask)" do
    let(:array) {[:a, :b, :c, :d]}
    it "pulls out single elements" do
      PieceAssembler.elements_indexed_by_bitmask(array, 0b1000).should == [:a]
      PieceAssembler.elements_indexed_by_bitmask(array, 0b0100).should == [:b]
      PieceAssembler.elements_indexed_by_bitmask(array, 0b0010).should == [:c]
      PieceAssembler.elements_indexed_by_bitmask(array, 0b0001).should == [:d]
    end
    
    it "pulls out all elements with 1111" do
      PieceAssembler.elements_indexed_by_bitmask(array, 0b1111).should == [:a, :b, :c, :d]
    end
    
    it "pulls out 2 elements with 1100 0110 etc" do
      PieceAssembler.elements_indexed_by_bitmask(array, 0b1001).should == [:a, :d]
      PieceAssembler.elements_indexed_by_bitmask(array, 0b1010).should == [:a, :c]
    end
  end
end
