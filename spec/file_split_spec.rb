require File.join(File.dirname(__FILE__), *%w[.. lib file_split])

describe FileSplit do
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
      let(:expected_filenames) { %w(test.mp3.o0 test.mp3.o1 test.mp3.o2) }
      before(:each) do
        @filepath = File.join(File.dirname(__FILE__), *%w[.. media test.mp3])
        @return_value = FileSplit.split_file_into_n_pieces(@filepath, 3)
      end

      it "splits a given file into n pieces, putting resulting files in the pwd" do
        expected_filenames.each do |filename|
          File.should exist(filename), "expected file #{filename} to exist"
        end
      end

      specify "rejoining the output files gives the same content as the original file" do
        require 'digest/sha1'
        bits = ""
        expected_filenames.each do |filename|
          bits << File.read(filename)
        end
        Digest::SHA1.hexdigest(bits).should == Digest::SHA1.hexdigest(File.read(@filepath))
      end
    end
  end
end
