#! /usr/bin/env ruby

require 'optparse'
require_relative 'numbering'

class MinutesProcessor
  def initialize(options)
    @options = options
    @title_number = Numbering.new
    @already_in_todo_list = false
  end

  protected
  def out
    @options[:outfile]
  end

  public
  def process_heading_line(line)
    num = case line
      when /^====/ then @title_number.h4
      when /^===/ then @title_number.h3
      when /^==/ then @title_number.h2
      when /^=/ then @title_number.h1
      else nil
    end
    if num.nil?
      out.print line
    else
      out.puts "#{line.chomp}  # TOPIC #{num} #"
    end
  end

  def process_minutes
    title_number = Numbering.new
    for line in @options[:infile]
      if line =~ /^=/ then
        process_heading_line(line)
      else
        @already_in_todo_list = @already_in_done_list = @already_in_future_list = false
        out.print line
      end
    end
  end
end

def main
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options] input_filename output_filename"

    opts.on("-n", "--notespace", "Format with space for notes") do |n|
      options[:notes] = n
    end
  end.parse!
  infile = ARGV[0] || '-'
  outfile = ARGV[1] || '-'
  options[:infile] = if infile == '-' then $stdin else File.open(infile) end
  options[:outfile] = if outfile == '-' then $stdout else File.open(outfile, 'w') end
  MinutesProcessor.new(options).process_minutes
end

main if $PROGRAM_NAME == __FILE__
