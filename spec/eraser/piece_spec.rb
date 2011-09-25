require File.join(File.dirname(__FILE__), *%w[.. .. eraser])
describe Eraser::Piece do
  context "with filename 'sonata.mp3', bitmask 0100" do
    let(:filename) {'sonata.mp3'}
    let(:bitmask) { 0b0100 }
    subject {Eraser::Piece.new(filename, bitmask)}

    its(:filename) {should == filename + '.0100'}

    describe "^(piece)" do
      it "xors with another piece's bitmask" do
        another_piece = mock(:bitmask => 0b1001)
        (subject ^ another_piece).should == 0b1101
      end
    end

    describe "content changing ops" do
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

      describe "overwrite(content)" do
        it "replaces the piece's content" do
          subject.overwrite('abc')
          subject.content.should == 'abc'
        end
      end

      describe "append(content)" do
        it "adds to the end of the piece" do
          subject.append('abc')
          subject.content.should == 'abc'
          subject.append('de')
          subject.content.should == 'abcde'
        end
      end
      
      describe "content" do
        it "returns the piece's persistent storage contents" do
          File.open(subject.filename, 'w') {|f| f<<'new content'}
          subject.content.should == 'new content'
        end
      end
    end
  end
end
