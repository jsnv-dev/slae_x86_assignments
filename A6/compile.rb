#!/usr/bin/env ruby
# Author: Jason Villaluna

require 'optparse'

def run
  parse_args
  compile_nasm(@original)
  compile_nasm(@poly)
  @original_shellcode = generate_shellcode(@original)
  @poly_shellcode = generate_shellcode(@poly)
  replace_shellcode
  compile_binary
  display_shellcode
rescue OptionParser::MissingArgument
  puts "\e[33mMissing argument:\e[0m"
  @parser.parse %w[--help]
rescue StandardError => e
  puts "\e[31m[-]\e[0m Encountered: \e[31m'#{e.class}' #{e}\e[0m"
  exit(1)
end

# Compile the nasm code
def compile_nasm(filename)
  `nasm -f elf32 -o #{filename}.o #{filename}.nasm`
  `ld -m elf_i386 -s -o #{filename} #{filename}.o`
end

# Generate shellcode using objdump
def generate_shellcode(filename)
  objdump = `objdump -d #{filename}`
  objdump.split("\n").map { |line| line.split("\t")[1] }
         .compact.map(&:split).join('\x').prepend('\x')
end

# Replace a value inside a file
def replace_content(filename)
  file_content = File.read(filename)
  yield(file_content)
  File.write(filename, file_content)
end

# Replace shellcode in the shellcode tester program
def replace_shellcode
  replace_content('./shellcode.c') do |c_code|
    c_code.gsub!(/\"\S+\"\;/, "\"#{@poly_shellcode}\"\;")
  end
end

# Compile the shellcode into binary with the help of the shellcode.c program
def compile_binary
  `gcc -fno-stack-protector -m32 -z execstack shellcode.c -o shellcode 2> /dev/null`
end

# print the shellcode values
def display_shellcode
  original_size = @original_shellcode.split('\\').size - 1
  poly_size = @poly_shellcode.split('\\').size - 1
  percentage = ((100.0 * poly_size / original_size) - 100).round(2)
  puts "Original shellcode    [#{original_size} bytes]: '#{@original_shellcode}'"
  puts "Polymorphic shellcode [#{poly_size} bytes]: '#{@poly_shellcode}'"
  puts "\nPercentage larger than the original: #{percentage} %"
end

def parse_args
  @parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on("--original", "-o ORIG_NASM", "Original nasm filename") do |value|
      @original = value
    end

    opts.on("--poly", "-p POLY_NASM", "Polymorphic nasm filename") do |value|
      @poly = value
    end

    opts.on_tail("--help", "-h", "Print options") do |show_help|
      warn opts
      exit(0)
    end
  end
  @parser.parse!
end

if __FILE__ == $PROGRAM_NAME
  run
  puts "\n\e[32m[+]\e[0m Successfully generated \e[32mshellcode\e[0m "\
       "binary for testing!"
end
