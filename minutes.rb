#! /usr/bin/env ruby

require 'optparse'
require_relative 'numbering'

class MinutesProcessor
  def initialize(options)
    @options = options
    @title_number = Numbering.new
    @already_in_todo_list = false
  end

  def process_heading_line(line)
    num = case line
      when /^====/ then @title_number.h4
      when /^===/ then @title_number.h3
      when /^==/ then @title_number.h2
      when /^=/ then @title_number.h1
      else nil
    end
    if num.nil?
      print line
    else
      print "\n\n\n\n\n\n" if @options[:notes]
      print line.sub(/^=+/, "#{num}.")
    end
  end

  def process_todo_line(line)
    puts "To Do:" unless @already_in_todo_list
    @already_in_todo_list = true
    if line =~ /^\s*TODO: ?/ then
      # Indent each To Do item by 2 spaces.
      print line.sub(/^\s*TODO: ?/, " * ")
    else
      # Continuation of a To Do item onto a new line:
      # make the first non-whitespace character a colon
      print line.sub(/^\s*: ?/, "       ")
    end
  end

  def process_minutes
    title_number = Numbering.new
    for line in $stdin
      if line =~ /^=/ then
        process_heading_line(line)
      elsif line =~ /^\s*TODO:/
        process_todo_line(line)
      elsif @already_in_todo_list && line =~ /^\s*:/
        process_todo_line(line)
      else
        @already_in_todo_list = false
        print line
      end
    end
  end
end

def main
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options] < minutes.creole"

    opts.on("-n", "--notespace", "Format with space for notes") do |n|
      options[:notes] = n
    end
  end.parse!
  MinutesProcessor.new(options).process_minutes
end

main if $PROGRAM_NAME == __FILE__
