# this is a helper class for generating symbolic output of diffs generated
# using Diff::LCS. Ex:
# require 'diff/lcs'
# require 'symboldiff'
# lines = ""
# sd = SymbolDiff.new(lines)
# Diff::LCS.traverse_sequences(a, b, sd)   # a and b are any enumerable -- arrays, strings, whatever
# or: Diff::LCS.traverse_balanced(a, b, sd)

class SymbolDiff
  attr_accessor :output

  def initialize(output1, output2 = nil)
    @out1 = output1
    @out2 = output2
    @dual_output = false
    if @out1 && @out2
      @dual_output = true
    end
  end

    # This will be called with both lines are the same
  def match(event)
    @out1 << "="
    if @dual_output
      @out2 << "="
    end
  end

    # This will be called when there is a line in A that isn't in B
  def discard_a(event)
    @out1 << "+"
  end

    # This will be called when there is a line in B that isn't in A
  def discard_b(event)
    if @dual_output
      @out2 << "-"
    else
      @out1 << "-"
    end
  end
  
  def change(event)
    if @dual_output
      @out1 << "*"
      @out2 << "*"
    else
      @out1 << "*"
    end
  end
end