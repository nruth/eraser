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

    # inline do |builder|
    #   builder.c_raw <<-C_CODE
    #   #include <stdio.h>
    # 
    #   static int content_xor_to_new_file(VALUE filenames) {
    #     double result = 0;
    #     long  i, len;
    #     VALUE *filenames = RARRAY_PTR(filenames);
    #     len = RARRAY_LEN(filenames);
    # 
    #     filenames = 
    # 
    #     for(i=0; i<len; i++) {
    #       result += NUM2DBL(arr[i]);
    #     }
    # 
    #     return rb_float_new(result/(double)len);
    #   }
    # 
    #   int xor_files(FILE *files[], int number_of_files, char *outputfilename) {
    #     int i;
    #     int tmp[number_of_files];
    #     int is_end_of_file = 0;
    # 
    #     // init tmp
    #     for (i = 0; i < number_of_files; i++) tmp[i] = 0;
    # 
    #     FILE* output;  
    #     output = fopen(outputfilename, "wb");
    # 
    #     // read a byte from each file and store them in tmp
    #     while ((tmp[0] = fgetc(files[0])) != EOF) {
    #       for (i = 1; i < number_of_files; i++) {
    #         tmp[i] = fgetc(files[i]);
    #       }
    # 
    #       // xor
    #       int j; 
    #       int xor_result = 0;
    #       for (j = 0; j < number_of_files-1; j++) {
    #         xor_result = tmp[j] ^ tmp[j+1];
    #       }
    # 
    #       // then write to new file
    #       fputc(xor_result, output);
    #     }
    # 
    #     fclose(output);
    # 
    #     return 0;
    #   }
    #   C_CODE
    # end

    def self.content_xor_to_new_file(pieces)
      if pieces.length == 1
        pieces.first
      else
        filename = pieces.first.original_filename
        new_bitmask = bitmask_xor(pieces)
        new_piece = Piece.new filename, new_bitmask
        xor_path = ::File.expand_path(::File.join(::File.dirname(__FILE__), *%w[.. .. xor]))
        command = "#{xor_path} #{new_piece.filename} #{pieces.map(&:filename).join(' ')}"
        `#{command}`
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