#!/usr/bin/env ruby

File.open "test.mp3" do |file|
  bytes_in_file = file.stat.size
  file.each_byte.with_index do |byte, index|
    puts byte
    break if index > 10
  end
end

