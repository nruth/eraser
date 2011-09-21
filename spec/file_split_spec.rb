require File.join(File.dirname(__FILE__), *%w[.. lib file_split])

describe FileSplit do
  describe "split_file_into_n_pieces(file, n_pieces)" do
    around(:each) do |example|
      require 'fileutils'
      mkdir 'tmp'
      cd 'tmp' do
        example.run
        `rm .o*`
      end
      rmdir tmp
    end

    it "splits a given file into n pieces, putting resulting files in the pwd" do
      file = File.join(File.dirname(__FILE__), *%w[.. media test.mp3])
      FileSplit.split_file_into_n_pieces(file, 3)
      %w(test.o1 test.o2 test.o3).each do |filename|
        File.should exist(filename)
      end
    end
  end
end
