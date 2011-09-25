require File.join(File.dirname(__FILE__), *%w[.. lib chopper])

describe Chopper do
  describe "split_file_into_n_pieces(file, n_pieces)" do
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

    describe "on an mp3" do
      let(:expected_filenames) { %w(test.mp3.o1 test.mp3.o2 test.mp3.o3) }
      let(:num_pieces) {3}
      before(:each) do
        @filepath = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. media test.mp3]))
        raise "Please copy an mp3 or other binary file to #{@filepath}" unless File.exists?(@filepath)
        @return_value = Chopper.new(@filepath).split_file_into_n_pieces(num_pieces)
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
        original_file_contents = File.read(@filepath)
        original_file_contents << (1..Padding.read_padding_bytes('test.mp3')).map {0}.pack('c*')
        Digest::SHA1.hexdigest(bits).should == Digest::SHA1.hexdigest(original_file_contents)
      end

      specify "reassembling the output files gives the same content as the original file" do
        require 'digest/sha1'
        require File.join(File.dirname(__FILE__), *%w[.. lib piece_assembler])
        reassembled = PieceAssembler.build_from_pieces(File.basename(@filepath), num_pieces)
        Digest::SHA1.hexdigest(reassembled).should == Digest::SHA1.hexdigest(File.read(@filepath))
      end
    end
  end
end
