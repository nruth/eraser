require File.join(File.dirname(__FILE__), *%w[.. .. eraser])

describe Eraser::Decoder do
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

    describe "decode_to_files(wanted_pieces)" do
      subject {Eraser::Decoder.new(pieces)}
      let(:pieces) do
        [0b1000, 0b0110, 0b0011, 0b0100].map {|c| Eraser::Piece.new('foo', c)}
      end
      it "finds working solutions and builds the files with them" do
        wanted_pieces = mock
        wanted_pieces.should_receive(:map).and_return wanted_pieces_bitmasks = mock
        solution = mock
        subject.should_receive(:solutions).with(wanted_pieces_bitmasks).and_return [solution]
        Eraser::Code.should_receive(:elements_indexed_by_bitmask).with(pieces, solution).and_return pieces_selected_by_solution = mock
        Eraser::Piece.should_receive(:content_xor_to_new_file).with(pieces_selected_by_solution)
        subject.decode_to_files(wanted_pieces)
      end
    end
  end


  describe "Combinatorial Logic" do
    describe "solution(wanted_pieces)" do
      subject {Eraser::Decoder.new(pieces)}
      let(:pieces) do
        [0b1000, 0b0110, 0b0011, 0b0100].map {|c| Eraser::Piece.new('foo', c)}
      end
      it "keeps only patterns satisfying combination_xors_to_wanted_piece?" do
        m1, m2, m3 = mock, mock, mock
        Eraser::Decoder.stub(:all_possible_combinations).and_return [m1, m2, m3]
        wanted_pieces = mock
      end

      it "returns a combination for the requested piece code" do
        subject.solutions([0b0100]).should == [0b1000]
        subject.solutions([0b0010]).should == [0b1010]
        subject.solutions([0b0001]).should == [0b1110]
        subject.solutions([0b1000]).should == [0b0001]
      end
    end

    describe "combination_xors_to_wanted_piece?(combination_of_pieces, wanted_piece)" do
      subject {Eraser::Decoder.new(pieces)}
      let(:pieces) do
        [0b1000, 0b0110, 0b0011, 0b0100].map {|c| Eraser::Piece.new('foo', c)}
      end

      specify "given a workable solution it returns true" do
        combination, wanted_piece = 0b0001, 0b1000
        subject.combination_xors_to?(combination, wanted_piece).should be_true #, "#{format("%#b", combination)} xor combination of #{pieces.map{|p| format("%#b", p)}.join(',')} should match #{format('%#b', wanted_piece)}"

        combination, wanted_piece = 0b1010, 0b0010
        subject.combination_xors_to?(combination, wanted_piece).should be_true #, "#{format("%#b", combination)} xor combination of #{pieces.map{|p| format("%#b", p)}.join(',')} should match #{format('%#b', wanted_piece)}"
      end

      specify "given a false solution it returns false" do
        wanted_piece = 0b1000
        combinations = [0b0000, 0b0110].each do |combination|
          subject.combination_xors_to?(combination, wanted_piece).should be_false #, "#{format("%#b", combination)} xor combination of #{pieces.map{|p| format("%#b", p)}.join(',')} should not match #{format('%#b', wanted_piece)}"
        end
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
  end
end
