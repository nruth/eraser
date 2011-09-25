module Eraser
  class File
    attr_reader :file
    def initialize(path)
      @file = ::File.new(path)
    end

    def name
      ::File.basename(path)
    end

    def path
      ::File.expand_path(@file.path)
    end

    def bytes_in_file
      file.stat.size
    end

    def method_missing(method, *args, &block)
      file.send method, *args, &block
    end

    def self.bitmask_appended_filename(filename, bitmask)
      format '%s.%04b', filename, bitmask
    end

    def self.appended_filename(filename, postfix)
      format '%s.%s', filename, postfix
    end
  end
end