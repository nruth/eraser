require File.join(File.dirname(__FILE__), *%w[.. .. eraser])

describe Eraser::Encoder do
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
    subject {Eraser::Encoder.new(file, 4)}

    describe "#encode_pieces_with_bitmask(pieces, bitmask)" do
      it "xors pieces according to the bitmask, creating a new piece" do
        pieces, bitmask = mock, mock
        Eraser::Code.should_receive(:elements_indexed_by_bitmask).with(pieces, bitmask).and_return selected_pieces = mock
        Eraser::Piece.should_receive(:content_xor_to_new_file).with selected_pieces
        subject.encode_pieces_with_bitmask(pieces, bitmask)
      end
    end


    describe "#encode" do
      let(:chopper) {mock}
      let(:encoder) {subject}
      let(:pieces) {mock}
      let(:code) {mock}
      before(:each) do
        Eraser::Chopper.stub(:new).and_return chopper
        Eraser::Code.stub(:new).and_return code
        code.stub(:basis_vectors).and_return []
        chopper.stub(:split_file_into_n_pieces).and_return pieces
      end

      it "returns all the encoded pieces" do
        subject.encode.length.should == 10
      end

      it "does not process the fundamental basis vectors twice" do
        code.stub(:basis_vectors).and_return [0b0010]
        encoder.should_receive(:encode_pieces_with_bitmask).with(anything(), 0b0010).once
      end

      it "splits the file into its fundamental pieces" do
        Eraser::Chopper.should_receive(:new).with(file).and_return chopper
        chopper.should_receive(:split_file_into_n_pieces).with(4).and_return pieces
        subject.encode
      end

      it "encodes the pieces according to the pattern" do
        bv1, bv2 = mock, mock
        code.should_receive(:basis_vectors).and_return [bv1, bv2]
        encoder.should_receive(:encode_pieces_with_bitmask).with(pieces, bv1).ordered
        encoder.should_receive(:encode_pieces_with_bitmask).with(pieces, bv2).ordered
        subject.encode
      end

      it "writes out the encoded pieces to disk"

      it "creates 10 encoded files, putting resulting files in the pwd" do
        file.stub!(:read).and_return 0b1111000011110000
        file.stub!(:name).and_return name = 'hepp'
        subject.encode
        expected_filenames = Eraser::Code.new.basis_vectors.map {|v| Eraser::File.bitmask_appended_filename(name, v)}
        expected_filenames.each do |filename|
          File.should exist(filename), "expected file #{filename} to exist"
        end
      end
    end
  end
end
