require 'fileutils'
require 'inline'

module Eraser
  class Piece
    attr_accessor :original_filename
    attr_accessor :bitmask
    def initialize(original_filename, bitmask, storage_path=nil)
      self.original_filename = ::File.basename(original_filename)
      self.bitmask = bitmask
      @storage_path = storage_path
    end

    def to_s
      filename
    end

    def filename
      filename = File.bitmask_appended_filename(original_filename, bitmask)
      @storage_path ? ::File.join(@storage_path, filename) : filename
    end

    def ^(piece)
      bitmask | piece.bitmask
    end

    # pieces = [Eraser::Piece] array to or
    def self.bitmask_xor(pieces)
      codes = pieces.map(&:bitmask).reduce(:'^')
    end

    inline do |builder|
      builder.include '<stdlib.h>'
      builder.include '<stdio.h>'
      builder.c_singleton <<-C_CODE
      /*
      rb_input_paths_array should be a ruby array of strings, 
      where the files referenced by path are of equal size
      result_path should be the path of the desired result file
      */
      static int xor_files(char* result_path, VALUE rb_input_paths){
        int counter;

        //set up files for reading
        int input_files_length = RARRAY(rb_input_paths)->len;
        FILE *input_files[input_files_length];
        for(counter=0; counter < input_files_length; counter++){
          char* path = RSTRING(rb_ary_shift(rb_input_paths))->ptr;
          input_files[counter] = fopen(path, "rb");
        }

        //read bytes and xor to output
        int byte = 0;
        FILE* output = fopen(result_path, "wb");
        while ((byte = fgetc(input_files[0])) != EOF) {
          for (counter = 1; counter < input_files_length; counter++) { 
            byte ^= fgetc(input_files[counter]);
          }
          fputc(byte, output);
        }

        //clean up
        for(counter=0; counter<input_files_length; counter++) { fclose(input_files[counter]); }
        fclose(output);
        return 0;
      }
      C_CODE
    end

    def self.content_xor_to_new_file(pieces)
      if pieces.length == 1
        pieces.first
      else
        filename = pieces.first.original_filename
        new_bitmask = bitmask_xor(pieces)
        new_piece = Piece.new filename, new_bitmask
        Piece.xor_files(new_piece.filename, pieces.map(&:filename))
        # ruby-inline alternative using external xor.c compiled to xor
        # marginally slower than rubyinline after first run (when inline compiles the c and is slower)
        # xor_path = ::File.expand_path(::File.join(::File.dirname(__FILE__), *%w[.. .. xor]))
        # command = "#{xor_path} #{new_piece.filename} #{pieces.map(&:filename).join(' ')}"
        # `#{command}`
        new_piece
      end
    end

    def open_file
      ::File.open(filename,"rb")
    end

    def overwrite(content)
      ::FileUtils.mkpath(@storage_path) if @storage_path && !::File.exist?(@storage_path)
      ::File.open(filename, 'wb') {|f| f.print content}
      self
    end

    def append(content)
      ::FileUtils.mkpath(@storage_path) if @storage_path && !::File.exist?(@storage_path)
      ::File.open(filename, 'ab') {|f| f.print content}
      self
    end

    def content
      ::File.open(filename,"rb") {|io| io.read}
    end

    def reset_content!
      ::FileUtils.mkpath(@storage_path) if @storage_path && !::File.exist?(@storage_path)
      ::File.open(filename, 'w') do
        #truncate file
      end
    end

    def destroy
      ::File.delete(filename) if ::File.exists?(filename)
    end

    def hash
      "#{original_filename}#{bitmask}".hash
    end

    def eql?(other)
      (self.original_filename == other.original_filename) && (self.bitmask == other.bitmask)
    end
  end
end