#! /usr/bin/env ruby

require 'optparse'
require_relative 'numbering'

class MinutesProcessor
  def initialize(options)
    @options = options
    @title_number = Numbering.new
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

  def process_minutes
    title_number = Numbering.new
    for line in $stdin
      if line =~ /^=/ then
        process_heading_line(line)
      else
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
