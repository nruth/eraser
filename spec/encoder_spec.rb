require File.join(File.dirname(__FILE__), *%w[.. lib eraser encoder])

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
    subject {Eraser::Encoder.new(file)}
    describe "#encode" do
      it "creates 10 encoded files, putting resulting files in the pwd" do
        file.stub!(:read).and_return 0b1111000011110000
        subject.encode

        expected_filenames.each do |filename|
          File.should exist(filename), "expected file #{filename} to exist"
        end
      end
    end
  end
end
