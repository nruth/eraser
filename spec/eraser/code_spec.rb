require File.join(File.dirname(__FILE__), *%w[.. .. eraser])

describe "elements_indexed_by_bitmask(array, bitmask)" do
  specify "basis_vectors" do
    Eraser::Code.basis_vectors.sort.should == 
    [0b1000, 0b0110, 0b0100, 0b0011, 0b0010, 0b1101, 0b0001, 0b1010, 0b1100, 0b0101].sort
  end

  let(:array) {[:a, :b, :c, :d]}
  it "pulls out single elements" do
    Eraser::Code.elements_indexed_by_bitmask(array, 0b1000).should == [:a]
    Eraser::Code.elements_indexed_by_bitmask(array, 0b0100).should == [:b]
    Eraser::Code.elements_indexed_by_bitmask(array, 0b0010).should == [:c]
    Eraser::Code.elements_indexed_by_bitmask(array, 0b0001).should == [:d]
  end

  it "pulls out all elements with 1111" do
    Eraser::Code.elements_indexed_by_bitmask(array, 0b1111).should == [:a, :b, :c, :d]
  end

  it "pulls out 2 elements with 1100 0110 etc" do
    Eraser::Code.elements_indexed_by_bitmask(array, 0b1001).should == [:a, :d]
    Eraser::Code.elements_indexed_by_bitmask(array, 0b1010).should == [:a, :c]
    Eraser::Code.elements_indexed_by_bitmask(array, 0b0110).should == [:b, :c]
  end
end