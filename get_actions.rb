#! /usr/bin/env ruby

# Extract just the headings and TODO items from the file.

require_relative 'minutes_reader'

class ToDoInterpreter < Meeting::MinutesInterpreter
  def initialize
    @outfile = $stdout
    @in_list = nil
  end

  def out
    @outfile
  end

  def start_special_list(list_type)
    @in_list = list_type
  end

  def end_special_list
    @in_list = false
  end

  def special_list_item_line(first_line, text, original_text)
    return unless @in_list == :TODO
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
