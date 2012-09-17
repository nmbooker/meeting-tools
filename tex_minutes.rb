#! /usr/bin/env ruby

# Extract just the headings and TODO items from the file.

require_relative 'minutes_reader'

# Minutes interpreter that just outputs current TODO items.
class TeXInterpreter < Meeting::MinutesInterpreter
  def initialize(options={})
    @outfile = $stdout
    @pre_topic = true
    @in_list = false
  end

  def at_beginning
    out.puts('\documentclass[a4paper,11pt]{article}')
    out.puts('\usepackage{fullpage}')
    out.puts '\usepackage[english]{babel}'
    out.puts '\usepackage{minutes}'
    out.puts ''
    out.puts '\begin{document}'
    out.puts '\selectlanguage{english}'
    out.puts '\begin{Minutes}{Meeting Minutes}'
  end

  def at_end
    out.puts('\end{Minutes}')
    out.puts('\end{document}')
  end

  def normal_line(text)
    text = text.chomp
    if @pre_topic
      case text
        when /^Location: (.*)$/ then out.puts("\\location{#{$1}}")
        when /^Present: (.*)$/ then out.puts("\\participant{#{$1}}")
        else out.puts("#{text}")
      end
    else
      escape_body!(text)
      out.puts("#{text}")
    end
  end

  def start_section(level, text)
    escape_body!(text)
    if @pre_topic
      out.puts("\\maketitle\n")
      @pre_topic = false
    end
    subs = 'sub' * (level - 1)
    out.puts("\\#{subs}topic{#{text}}\n")
  end

  def end_section
    #out.puts("END SECTION")
  end

  def start_special_list(list_type)
    if @in_list
      end_special_list
    end
    @in_list = true
    out.puts("\\emph{#{list_type}}")
    out.puts("\\begin{itemize}")
  end

  def start_special_list_item
    out.write("\\item ")
  end

  def special_list_item_line(text)
    escape_body!(text)
    out.write("#{text}")
  end

  def end_special_list_item
    out.puts("\n")
  end

  def end_special_list
    out.puts("\\end{itemize}")
    @in_list = false
  end

  private
  def out
    @outfile
  end

  def escape_body!(text)
    text.gsub!('_', '\_')
    return text
  end
end

interpreter = TeXInterpreter.new
reader = Meeting::MinutesReader.new(interpreter)
reader.process_file($stdin)
