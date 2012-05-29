#! /usr/bin/env ruby

# Extract just the headings and TODO items from the file.

require_relative 'minutes_reader'

# Minutes interpreter that just outputs current TODO items.
class ToDoInterpreter < Meeting::MinutesInterpreter
  def initialize(options={})
    @outfile = $stdout
    @who_filter = options[:people]
    @who_is_it = nil
  end

  # To-do lists are output as bulleted lists.
  def special_list_item_line(text)
    return unless reader.in_special_list?(:TODO)
    if reader.list_item_line_number == 1
      if @who_filter
        matchobj = text.match(/([a-zA-Z1-9\/,\?]+):/)
        people = matchobj ? matchobj[1] : nil
        @who_is_it = nil
        unless people.nil?
          #        get rid of ? marks    split on / and ,
          people = people.gsub(/\?/, '').split(/[\/,]/)
          @who_is_it = people.empty? ? @who_filter : people
        end
      end
      if person_matches_filter
        out.write "* " + text
      end
    else
      if person_matches_filter
        out.write "  " + text
      end
    end
  end

  # We just output the section headings as found in the original text.
  def start_section(level, title)
    out.write reader.original_text
  end

  # Put an extra blank line at the end of each section.
  def end_section
    out.puts ""
  end

  private
  def out
    @outfile
  end

  def person_matches_filter
    return true unless @who_filter
    return true if @who_is_it.nil? or @who_is_it.empty?
    return !(@who_is_it & @who_filter).empty?
  end
end

people = ARGV.empty? ? nil : ARGV
interpreter = ToDoInterpreter.new(:people => people)
reader = Meeting::MinutesReader.new(interpreter)
reader.process_file($stdin)
