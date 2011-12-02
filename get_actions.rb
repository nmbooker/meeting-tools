#! /usr/bin/env ruby

# Extract just the headings and TODO items from the file.

require_relative 'minutes_reader'

class ToDoInterpreter < Meeting::MinutesInterpreter
  def initialize
    @outfile = $stdout
  end

  def out
    @outfile
  end

  def special_list_item_line(first_line, text, original_text)
    return unless reader.special_list_type == :TODO
    if first_line
      out.write "* " + text
    else
      out.write "  " + text
    end
  end

  def start_section(level, title, original_text)
    out.write original_text
  end

  def end_section
    out.puts ""
  end
end

interpreter = ToDoInterpreter.new
reader = Meeting::MinutesReader.new(interpreter)
reader.process_file($stdin)
