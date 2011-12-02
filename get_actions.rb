#! /usr/bin/env ruby

# Extract just the headings and TODO items from the file.

require_relative 'minutes_reader'

# Minutes interpreter that just outputs current TODO items.
class ToDoInterpreter < Meeting::MinutesInterpreter
  def initialize
    @outfile = $stdout
  end

  # To-do lists are output as bulleted lists.
  def special_list_item_line(text, original_text)
    return unless reader.in_special_list?(:TODO)
    if reader.list_item_line_number == 1
      out.write "* " + text
    else
      out.write "  " + text
    end
  end

  # We just output the section headings as found in the original text.
  def start_section(level, title, original_text)
    out.write original_text
  end

  # Put an extra blank line at the end of each section.
  def end_section
    out.puts ""
  end

  private
  def out
    @outfile
  end
end

interpreter = ToDoInterpreter.new
reader = Meeting::MinutesReader.new(interpreter)
reader.process_file($stdin)
