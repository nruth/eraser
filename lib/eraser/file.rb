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
  end
end