#! /usr/bin/env ruby

require 'optparse'
require_relative 'numbering'

def main
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options] < minutes.creole"

    opts.on("-n", "--notespace", "Format with space for notes") do |n|
      options[:notes] = n
    end
  end.parse!

  title_number = Numbering.new
  for line in $stdin
    num = case line
      when /^====/ then title_number.h4
      when /^===/ then title_number.h3
      when /^==/ then title_number.h2
      when /^=/ then title_number.h1
      else nil
    end
    if num.nil?
      print line
    else
      print "\n\n\n\n\n\n" if options[:notes]
      print line.sub(/^=+/, "#{num}.")
    end
  end
end

main if $PROGRAM_NAME == __FILE__
