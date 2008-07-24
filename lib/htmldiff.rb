# this is a helper class for generating html output of diffs generated
# using Diff::LCS. Ex:
# require 'diff/lcs'
# require 'htmldiff'
# lines = ""
# hd = HTMLDiff.new(lines)
# Diff::LCS.traverse_sequences(a, b, hd)   # a and b are any enumerable -- arrays, strings, whatever
# or: Diff::LCS.traverse_balanced(a, b, hd)
# hd.close

class HTMLDiff
  attr_accessor :output

# FIXME Split changes among 2 streams so that sources can be easily compared
  def initialize(output1, output2 = nil)
    @out1 = output1
    @out2 = output2
    @dual_output = false
    if @out1 && @out2
      @dual_output = true
    end
    @last_type = nil
    @finished_a = false
    @finished_b = false
  end

    # This will be called with both lines are the same
  def match(event)
    check_open_close("match")
    @out1 << "#{event.old_element}"
    if @dual_output
      @out2 << "#{event.old_element}"
    end
  end

    # This will be called when there is a line in A that isn't in B
  def discard_a(event)
    check_open_close("only_a")
    @out1 << "#{event.old_element}"
  end

    # This will be called when there is a line in B that isn't in A
  def discard_b(event)
    check_open_close("only_b")
    if @dual_output
      @out2 << "#{event.new_element}"
    else
      @out1 << "#{event.new_element}"
    end
  end
  
  def change(event)
    check_open_close("changed")
    if @dual_output
      @out1 << "#{event.old_element}"
      @out2 << "#{event.new_element}"
    else
      @out1 << "#{event.new_element}"
    end
  end
  
  def check_open_close(src)
    if @last_type == nil
      open(src)
    elsif @last_type != src
      close
      open(src)
    end
    @last_type = src
  end
  
  def open(src)
    @out1 << "<span class='#{src}'>"
    if @dual_output
      @out2 << "<span class='#{src}'>"
    end
  end
  
  def close
    @out1 << "</span>"
    if @dual_output
      @out2 << "</span>"
    end
  end
end