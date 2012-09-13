#! /usr/bin/env ruby

require 'optparse'
require_relative 'numbering'
require_relative 'minutes_reader'

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
    if @options[:creole]
      out.print('=' + line)
      return
    end
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
      out.print "\n\n\n" if @options[:notes]
      out.print line.sub(/^=+/, "#{num}.")
    end
  end

  def process_todo_line(line)
    out.puts "To Do:" unless @already_in_todo_list
    @already_in_todo_list = true
    if line =~ /^\s*(TODO|@T): ?/ then
      # Indent each To Do item by 2 spaces.
      out.print line.sub(/^\s*(TODO|@T): ?/, "* ")
    else
      # Continuation of a To Do item onto a new line:
      # make the first non-whitespace character a colon
      out.print line.sub(/^\s*: ?/, "       ")
    end
  end

  def process_done_line(line)
    out.puts "Done:" unless @already_in_done_list
    @already_in_done_list = true
    if line =~ /^\s*(DONE|@D): ?/ then
      out.print line.sub(/^\s*(DONE|@D): ?/, "* ")
    else
      out.print line.sub(/^\s*: ?/, "      ")
    end
  end

  def process_future_line(line)
    out.puts "Future:" unless @already_in_future_list
    @already_in_future_list = true
    if line =~ /^\s*(FUTURE|@F): ?/ then
      out.print line.sub(/^\s*(FUTURE|@F): ?/, "* ")
    else
      out.print line.sub(/^\s*: ?/, "      ")
    end
  end

  def process_minutes
    title_number = Numbering.new
    for line in @options[:infile]
      if line =~ /^=/ then
        process_heading_line(line)
      elsif line =~ /^\s*(TODO|@T):/
        process_todo_line(line)
      elsif @already_in_todo_list && line =~ /^\s*:/
        process_todo_line(line)
      elsif line =~ /^\s*(DONE|@D):/
        process_done_line(line)
      elsif @already_in_done_list && line =~ /^\s*:/
        process_done_line(line)
      elsif line =~ /^\s*(FUTURE|@F):/
        process_future_line(line)
      elsif @already_in_future_list && line =~ /^\s*:/
        process_future_line(line)
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
    opts.on("-c", "--creole", "Format with Creole rather than doing numbering") do |c|
      options[:creole] = c
    end
  end.parse!
  infile = ARGV[0] || '-'
  outfile = if ARGV[1] then ARGV[1]
            elsif infile == '-' then '-'
            else infile + (options[:notes] ? '.notes' : '.txt')
            end
  options[:infile] = if infile == '-' then $stdin else File.open(infile) end
  options[:outfile] = if outfile == '-' then $stdout else File.open(outfile, 'w') end
  MinutesProcessor.new(options).process_minutes
end

main if $PROGRAM_NAME == __FILE__
