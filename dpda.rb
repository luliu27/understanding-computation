# deterministic pushdown automata

###
# ruby regex for infinite nested brackets
# balanced = 
#   /
#     \A
#     (?<brackets>
#       \(
#       \g<brackets>*
#       \)
#     )
#     *
#     \z  # match end of string
#   /x
# ['(()', '())', '(())', '(()(()()))', '((((((((((()))))))))))'].grep(balanced)
# => ["(())", "(()(()()))", "((((((((((()))))))))))"]

class Stack < Struct.new(:contents)
  def push(char)
    Stack.new([char] + contents)
  end

  def pop
    Stack.new(contents.drop(1))
  end

  def top
    contents.first
  end

  def inspect
    "#<Stack (#{top})#{contents.drop(1).join}>"
  end
end

# PushDown Automata configuration wraps state and stack together 
class PDAConfiguration < Struct.new(:state, :stack)
  STUCK_STATE = Object.new

  def stuck
    PDAConfiguration.new(STUCK_STATE, stack)
  end

  def stuck?
    state == STUCK_STATE
  end
end

class PDARule < Struct.new(:state, :char, :next_state,
                           :pop_char, :push_chars)
  def applies_to?(configuration, char)
    self.state == configuration.state &&
      self.pop_char == configuration.stack.top &&
      self.char == char
  end

  def follow(configuration)
    PDAConfiguration.new(next_state, next_stack(configuration))
  end

  def next_stack(configuration)
    popped_stack = configuration.stack.pop
    # stack is FILO, so reverse here
    # use Enumerable.inject(initial) {|memo, obj| block} -> memo
    push_chars.reverse.
      inject(popped_stack) { |stack, char| stack.push(char) }
  end
end

class DPDARulebook < Struct.new(:rules)
  def next_configuration(configuration, char)
    rule_for(configuration, char).follow(configuration)
  end

  def rule_for(configuration, char)
    rules.detect { |rule| rule.applies_to?(configuration, char) }
  end

  def applies_to?(configuration, char)
    !rule_for(configuration, char).nil?
  end

  def follow_free_moves(configuration)
    if applies_to?(configuration, nil)
      follow_free_moves(next_configuration(configuration, nil))
    else
      configuration
    end
  end
end

class DPDA < Struct.new(:current_configuration, :accept_states, :rulebook)
  def current_configuration
    rulebook.follow_free_moves(super)
  end

  def next_configuration(char)
    if rulebook.applies_to?(current_configuration, char)
      rulebook.next_configuration(current_configuration, char)
    else
      current_configuration.stuck
    end
  end

  def stuck?
    current_configuration.stuck?
  end

  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def read_char(char)
    self.current_configuration = next_configuration(char)
  end

  def read_string(string)
    string.chars.each do |char|
      read_char(char) unless stuck?
    end
  end
end

class DPDADesign < Struct.new(:start_state, :bottom_char,
                              :accept_states, :rulebook)
  def to_dpda
    start_stack = Stack.new([bottom_char])
    start_configuration =
      PDAConfiguration.new(start_state, start_stack)
    DPDA.new(start_configuration, accept_states, rulebook)
  end

  def accepts?(string)
    to_dpda.tap { |dpda| dpda.read_string(string) }.accepting?
  end  
end


# example -- balanced parentheses
# rulebook = DPDARulebook.new([
#     PDARule.new(1, '(', 2, '$', ['b', '$']),
#     PDARule.new(2, '(', 2, 'b', ['b', 'b']),
#     PDARule.new(2, ')', 2, 'b', []),
#     PDARule.new(2, nil, 1, '$', ['$'])])
# dpda_design = DPDADesign.new(1, '$', [1], rulebook)
# dpda_design.accepts?('(((((((((())))))))))')
# => true
# dpda_design.accepts?('()(())((()))(()(()))')
# => true
# dpda_design.accepts?('(()(()(()()(()()))()')
# => false
