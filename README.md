Running the demo
================

0. (sudo) gem install bundler
1. (sudo) bundle install
2. gcc -o xor xor.c
3. copy a binary file to media/test.mp3
4. ./demo.rb or explore for yourself

Running tests
=============

1. bundle install --with=development
2. run `rspec spec`


Problems with RubyInline
========================

If you can't get the inline C code in lib/piece.rb to compile, e.g. missing header files, then you can switch to the
backticks-xor branch, and use the standalone xor program.

Compile the standalone xor.c with: gcc -o xor xor.c


DISCLAIMER
==========

This probably doesn't run on Windows.