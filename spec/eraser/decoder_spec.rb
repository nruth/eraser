require File.join(File.dirname(__FILE__), *%w[.. .. eraser])

describe Eraser::Decoder do
  describe "Combinatorial Logic" do
    describe "decode_pieces(wanted_pieces)" do
      let(:pieces) {[0b1000, 0b0110, 0b0011, 0b0100]}
      subject {Eraser::Decoder.new(pieces)}
      it "returns a combination for the requested piece code" do
        subject.decode_pieces([0b0100]).should == [0b0001]
        subject.decode_pieces([0b0010]).should == [0b0101]
        subject.decode_pieces([0b0001]).should == [0b0111]
        subject.decode_pieces([0b1000]).should == [0b1000]
      end
    end

    describe "all_possible_combinations for 4 items" do
      subject {Eraser::Decoder.all_possible_combinations}
      its(:length) {should eq(15) }
      it "should contain all 4 bit binary combinations" do
        subject.should == [ 
          0b0001, 0b0010, 0b0011, 0b0100, 
          0b0101, 0b0110, 0b0111, 0b1000, 
          0b1001, 0b1010, 0b1011, 0b1100, 
          0b1101, 0b1110, 0b1111
        ]
      end
    end

    describe "combination_xors_to_wanted_piece?(combination_of_pieces, wanted_piece)" do
      let(:pieces) {[0b1000, 0b0110, 0b0011, 0b0100]}
      subject {Eraser::Decoder.new(pieces)}

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
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b1000).should == [:a]
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b0100).should == [:b]
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b0010).should == [:c]
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b0001).should == [:d]
      end

      it "pulls out all elements with 1111" do
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b1111).should == [:a, :b, :c, :d]
      end

      it "pulls out 2 elements with 1100 0110 etc" do
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b1001).should == [:a, :d]
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b1010).should == [:a, :c]
        Eraser::Decoder.elements_indexed_by_bitmask(array, 0b0110).should == [:b, :c]
      end
    end
  end

  describe "Decoding" do

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

    describe "initialized with a file" do
      let(:file) {mock}
      subject {Eraser::Encoder.new(file)}
      describe "#encode" do
        it "creates 10 encoded files, putting resulting files in the pwd" do
          pending do
            file.stub!(:read).and_return 0b1111000011110000
            subject.encode

            expected_filenames.each do |filename|
              File.should exist(filename), "expected file #{filename} to exist"
            end
          end
        end
      end
    end
  end
end
