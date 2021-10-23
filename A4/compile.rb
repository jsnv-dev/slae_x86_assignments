#!/usr/bin/env ruby
# Author: Jason Villaluna

require 'optparse'

def run
  parse_args
  compile_nasm(@filename)
  @shellcode = generate_shellcode(@filename)
  encode
  replace_encoded_shellcode
  compile_nasm
  @new_shellcode = generate_shellcode
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
def compile_nasm(filename = 'decoder')
  `nasm -f elf32 -o #{filename}.o #{filename}.nasm`
  `ld -m elf_i386 -s -o #{filename} #{filename}.o`
end

# Generate shellcode using objdump
def generate_shellcode(filename = 'decoder')
  objdump = `objdump -d #{filename}`
  objdump.split("\n").map { |line| line.split("\t")[1] }
         .compact.map(&:split).join('\x').prepend('\x')
end

# Encode the shellcode
def encode
  # Will add 1 if the input is even and subtract 1 if odd
  # and then reverse the arrangement of the bytes
  encoded = @shellcode.split('\\x').map do |input|
    input_ = input.to_i(16)
    input_.even? ? input_ + 1 : input_ - 1
  end[1..-1].reverse
  @length = encoded.size

  # Format for the message in #display_shellcode
  @encoded =  encoded.map { |number| number.to_s(16) }.join('\x').prepend('\x')

  # Format needed for that nasm code
  @encoded_shellcode = @encoded.gsub('\\', ',0')[1..-1]
end

# Replace a value inside a file
def replace_content(filename)
  file_content = File.read(filename)
  yield(file_content)
  File.write(filename, file_content)
end

# Replace shellcode in the shellcode tester program
def replace_encoded_shellcode
  replace_content('./decoder.nasm') do |nasm_code|
    nasm_code.gsub!(/LENGTH equ .*$/, "LENGTH equ #{@length}")
    nasm_code.gsub!(/code: db .*$/, "code: db #{@encoded_shellcode}")
  end
end

# Replace shellcode in the shellcode tester program
def replace_shellcode
  replace_content('./shellcode.c') do |c_code|
    c_code.gsub!(/\"\S+\"\;/, "\"#{@new_shellcode}\"\;")
  end
end

# Compile the shellcode into binary with the help of the shellcode.c program
def compile_binary
  `gcc -fno-stack-protector -m32 -z execstack shellcode.c -o shellcode 2> /dev/null`
end

# print the shellcode values
def display_shellcode
  puts "Input shellcode:   '#{@shellcode}'"
  puts "Encoded shellcode: '#{@encoded}'"
  puts "Final shellcode:   '#{@new_shellcode}'"
end

def parse_args
  @parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on("--nasm", "-n FILENAME", "Nasm file to be encoded.") do |value|
      @filename = value
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
