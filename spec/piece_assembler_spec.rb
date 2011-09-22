require File.join(File.dirname(__FILE__), *%w[.. lib piece_assembler])

describe PieceAssembler do
  describe "decode_pieces(wanted_pieces)" do
    let(:pieces) {[0b1000, 0b0110, 0b0011, 0b0100]}
    subject {PieceAssembler.new(pieces)}
    it "returns a combination for the requested piece code" do
      subject.decode_pieces([0b0100]).should == [0b0001]
      subject.decode_pieces([0b0010]).should == [0b0101]
      subject.decode_pieces([0b0001]).should == [0b0111]
      subject.decode_pieces([0b1000]).should == [0b1000]
    end
  end

  describe "all_possible_combinations for 4 items" do
    subject {PieceAssembler.all_possible_combinations}
    its(:length) {should eq(15) }
    it "should contain all 4 bit binary combinations" do
      subject.should == [ 0b0001, 0b0010, 0b0011, 0b0100, 
                          0b0101, 0b0110, 0b0111, 0b1000, 
                          0b1001, 0b1010, 0b1011, 0b1100, 
                          0b1101, 0b1110, 0b1111]
    end
  end

  describe "combination_xors_to_wanted_piece?(combination_of_pieces, wanted_piece)" do
    let(:pieces) {[0b1000, 0b0110, 0b0011, 0b0100]}
    subject {PieceAssembler.new(pieces)}

    specify "given a workable solution it returns true" do
      combination, wanted_piece = 0b1000, 0b1000
      subject.combination_xors_to_wanted_piece?(combination, wanted_piece).should be_true, "#{format("%#b", combination)} xor combination of #{pieces.map{|p| format("%#b", p)}.join(',')} should match #{format('%#b', wanted_piece)}"

      combination, wanted_piece = 0b0101, 0b0010
      subject.combination_xors_to_wanted_piece?(combination, wanted_piece).should be_true, "#{format("%#b", combination)} xor combination of #{pieces.map{|p| format("%#b", p)}.join(',')} should match #{format('%#b', wanted_piece)}"
    end

    specify "given a false solution it returns false" do
      wanted_piece = 0b1000
      combinations = [0b0000, 0b0110].each do |combination|
        subject.combination_xors_to_wanted_piece?(combination, wanted_piece).should be_false, "#{format("%#b", combination)} xor combination of #{pieces.map{|p| format("%#b", p)}.join(',')} should not match #{format('%#b', wanted_piece)}"
      end
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
      PieceAssembler.elements_indexed_by_bitmask(array, 0b0110).should == [:b, :c]
    end
  end
end
