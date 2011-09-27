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
  
  it "creates 10 encoded files, putting resulting files in the pwd" do
    file = mock
    file.stub(:read).and_return '12 14 49 12'
    file.stub(:name).and_return name = 'hepp'
    file.stub(:bytes_in_file).and_return 16
    encoder = Eraser::Encoder.new(file, 4)
    encoder.encode
    expected_filenames = Eraser::Code.basis_vectors.map {|v| Eraser::File.bitmask_appended_filename(name, v)}
    expected_filenames.each do |filename|
      File.should exist(filename), "expected file #{filename} to exist"
    end
  end

  describe "initialized with a file" do
    let(:file) {mock}
    subject {Eraser::Encoder.new(file, 4)}

    describe "#encode_pieces_with_bitmask(pieces, bitmask)" do
      it "xors pieces according to the bitmask, creating a new piece" do
        pieces, bitmask = mock(:length => 4), mock
        Eraser::Code.should_receive(:elements_indexed_by_bitmask).with(pieces, bitmask).and_return selected_pieces = mock
        Eraser::Piece.should_receive(:content_xor_to_new_file).with selected_pieces
        subject.encode_pieces_with_bitmask(pieces, bitmask)
      end
    end


    describe "#encode" do
      let(:chopper) {mock}
      let(:encoder) {subject}
      let(:code) {mock}
      before(:each) do
        Eraser::Chopper.stub(:new).and_return chopper
        chopper.stub(:split_file_into_n_pieces).and_return []
        encoder.stub(:encode_pieces).and_return []
      end

      it "splits the file into its fundamental pieces" do
        Eraser::Chopper.should_receive(:new).with(file).and_return chopper
        chopper.should_receive(:split_file_into_n_pieces).with(4).and_return []
        subject.encode
      end
      
      it "calls encode_pieces on the fundamental pieces, returning their sum" do
        chopper.should_receive(:split_file_into_n_pieces).with(4).and_return pieces = mock
        encoder.should_receive(:encode_pieces).with(pieces).and_return encoded_pieces = mock
        pieces.should_receive('+').with(encoded_pieces).and_return result = mock
        subject.encode.should == result
      end

      # it "processes each non-fundamental basis vector once" do
      #   to_process = Eraser::Code.basis_vectors - Eraser::Code.fundamental_bitmasks(4)
      #   to_process.each do |bits|
      #     encoder.should_receive(:encode_pieces_with_bitmask).with(anything(), bits).once
      #   end
      #   subject.encode
      # end
      # 
      # 
      # 
      # it "encodes the pieces according to the pattern" do
      #   bv1, bv2 = mock, mock
      #   code.should_receive(:basis_vectors).and_return [bv1, bv2]
      #   encoder.should_receive(:encode_pieces_with_bitmask).with(pieces, bv1).ordered
      #   encoder.should_receive(:encode_pieces_with_bitmask).with(pieces, bv2).ordered
      #   subject.encode
      # end
    end
  end
end
