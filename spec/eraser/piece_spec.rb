require File.join(File.dirname(__FILE__), *%w[.. .. eraser])
describe Eraser::Piece do
  specify "Piece.bitmask_xor(pieces)" do
    o1 = mock(:bitmask => 0b1101)
    o2 = mock(:bitmask => 0b0001) 
    o3 = mock(:bitmask => 0b0001)
    Eraser::Piece.bitmask_xor([o1, o2, o3]).should == 0b1101

    o1 = mock(:bitmask => 0b0001)
    o2 = mock(:bitmask => 0b0100) 
    o3 = mock(:bitmask => 0b1000)
    Eraser::Piece.bitmask_xor([o1, o2, o3]).should == 0b1101
  end

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

      describe "Piece.content_xor_to_new_file([o1, o2, o3])" do
        let(:p1) {Eraser::Piece.new('test.foo', 0b1000).tap{|p|p.overwrite(0b0011)}}
        let(:p2) {Eraser::Piece.new('test.foo', 0b0100).tap{|p|p.overwrite(0b0111)}}
        describe "2 pieces" do
          it "makes a new piece with the xor'd contents" do
            new_piece = Eraser::Piece.content_xor_to_new_file([p1, p2])
            new_piece.original_filename.should == p1.original_filename
            new_piece.bitmask.should == p1.bitmask ^ p2.bitmask
            new_piece.content.should == [0b0011 ^ 0b0111].pack('c*')
          end
        end
        describe "1 piece" do
          it "returns the same piece" do
            Eraser::Piece.content_xor_to_new_file([p1]).should == p1
          end
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
      
      describe "changing path" do
        it "writes to the new directory" do
          Eraser::Piece.new('foo.jpg', 0b0101, 'node1').overwrite 'data'
          File.should exist('node1/foo.jpg.0101')
          File.read('node1/foo.jpg.0101').should == 'data'
        end
      end
    end
  end
end
