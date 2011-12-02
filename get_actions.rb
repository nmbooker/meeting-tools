#! /usr/bin/env ruby

# Extract just the headings and TODO items from the file.

require_relative 'minutes_reader'

class ToDoInterpreter < Meeting::MinutesInterpreter
  def initialize
    @outfile = $stdout
    @in_list = nil
    @in_item = false
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

  def start_special_list_item
    @new_item = true
  end

  def end_special_list_item
    @new_item = false
  end

  def special_list_item_line(text, original_text)
    text = text.strip
    if @new_item
      out.puts "* " + text
    else
      out.puts "  " + text
    end
  end

  def start_section(level, title, original_text)
    out.write original_text
  end

  def end_section
    puts ""
  end
end

interpreter = ToDoInterpreter.new
reader = Meeting::MinutesReader.new(interpreter)
reader.process_file($stdin)
