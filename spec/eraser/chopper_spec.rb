require File.join(File.dirname(__FILE__), *%w[.. .. eraser])

describe Eraser::Chopper do
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

  describe "initialised with a 16 byte file" do
    let(:filename) {mock}
    let(:input_file) {mock(:bytes_in_file => 16, :name => filename)}
    subject {Eraser::Chopper.new(input_file)}
    describe "split_file_into_n_pieces(4)" do
      it "splits a 16 byte file into 4x4B pieces masked 0001 0010 0100 1000" do
        input_file.should_receive(:read).with(4).exactly(4).times.and_return data = mock
        [0b0001, 0b0010, 0b0100, 0b1000].each do |bitmask|
          Eraser::Piece.should_receive(:new).with(filename, bitmask).and_return piece = mock
          piece.should_receive(:overwrite).with(data).and_return piece
        end
        subject.split_file_into_n_pieces(4)
      end
      
      it "returns the piece instances" do
        pieces = []
        input_file.stub(:read).and_return mock
        [0b0001, 0b0010, 0b0100, 0b1000].each do |bitmask|
          Eraser::Piece.stub(:new).and_return piece = mock.as_null_object
          pieces =+ piece
        end
        subject.split_file_into_n_pieces(4)
      end
    end
  end
  
  describe "initialised with an 18 byte file" do
    let(:filename) {'vicky.jpg'}
    let(:input_file) {mock(:bytes_in_file => 18, :name => filename)}
    subject {Eraser::Chopper.new(input_file)}
    describe "split_file_into_n_pieces(4)" do
      it "splits into 4x5B pieces masked 0001 0010 0100 1000, pads the last file with 2 bytes of zeros, and records the padding" do
        input_file.should_receive(:read).with(5).exactly(4).times.and_return data = mock
        last_piece = nil
        [0b0001, 0b0010, 0b0100, 0b1000].each do |bitmask|
          Eraser::Piece.should_receive(:new).with(filename, bitmask).and_return piece = mock
          piece.should_receive(:overwrite).with(data).and_return piece
          last_piece = piece
        end
        last_piece.should_receive(:append).with([0,0].pack('c*'))
        subject.split_file_into_n_pieces(4)
        File.read(filename+'.end_padding').should == '2'
      end
    end
  end


  describe "with a real file, split_file_into_n_pieces(file, n_pieces)" do
    let(:sample_file_path) {File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. media test.mp3]))}
    let(:expected_filenames) { %w(test.mp3.0001 test.mp3.0010 test.mp3.0100 test.mp3.1000) }
    let(:num_pieces) {4}
    before(:each) do
      # pending "need the implementation"
      @file = Eraser::File.new sample_file_path
      raise "Please copy an mp3 or other binary file to #{sample_file_path}" unless File.exists?(sample_file_path)
      @return_value = Eraser::Chopper.new(@file).split_file_into_n_pieces(num_pieces)
    end

    it "splits a given file into n pieces, putting resulting files in the pwd" do
      expected_filenames.each do |filename|
        File.should exist(filename), "expected file #{filename} to exist"
      end
    end

    it "produces files of equal byte-length" do
      filesizes = expected_filenames.map {|f| File.stat(f).size}
      filesizes.each {|size| size.should == filesizes.first}
    end

    specify "rejoining the output files gives the same content as the original file when zero padded" do
      require 'digest/sha1'
      bits = ""
      expected_filenames.each {|f| bits << File.read(f)}
      original_file_contents = File.read(sample_file_path)
      original_file_contents << (1..Eraser::Padding.read_padding_bytes('test.mp3')).map {0}.pack('c*')
      Digest::SHA1.hexdigest(bits).should == Digest::SHA1.hexdigest(original_file_contents)
    end

    specify "reassembling the output files gives the same content as the original file" do
      require 'digest/sha1'
      reassembled = Eraser::Decoder.build_from_pieces(@file.name, num_pieces)
      Digest::SHA1.hexdigest(reassembled).should == Digest::SHA1.hexdigest(File.read(sample_file_path))
    end
  end
end
