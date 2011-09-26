#! /usr/bin/env ruby

require 'optparse'

# Track numbering of sections or bulleted lists, up to 4 levels
class Numbering
  def initialize
    @l1 = @l2 = @l3 = @l4 = 0
  end

  # Get next level 1 number
  def h1
    @l1 += 1
    @l2 = @l3 = @l4 = 0
    "#{@l1}"
  end

  # Get next level 2 number
  def h2
    @l2 += 1
    @l3 = @l4 = 0
    "#{@l1}.#{@l2}"
  end

  # Get next level 3 number
  def h3
    @l3 += 1
    @l4 = 0
    "#{@l1}.#{@l2}.#{@l3}"
  end

  # Get next level 4 number
  def h4
    @l4 += 1
    "#{@l1}.#{@l2}.#{@l3}.#{@l4}"
  end
end

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
