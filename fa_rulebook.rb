require 'set'

class FARule < Struct.new(:state, :char, :next_state)
  def applies_to?(state, char)
    self.state == state && self.char == char
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} -- #{char} --> #{next_state.inspect}>"
  end
end

class DFARulebook < Struct.new(:rules)
  def next_state(state, char)
    rule_for(state, char).follow
  end

  # Enumerable.detect pass each entry in enum in block.
  # Return the first for which block is not false,
  # or return nil if there is no object match or use ifnone
  # if return nil, simulation will crash.
  # therefore, this is DFA rulebook rather than FA rulebook
  # because it only works properly if the determinism
  # constraints are respected.
  def rule_for(state, char)
    rules.detect { |rule| rule.applies_to?(state, char) }
  end
end

class DFA < Struct.new(:current_state, :accept_states, :rule_book)
  def accepting?
    self.accept_states.include?(self.current_state)
  end

  def read_char(char)
    self.current_state = rule_book.next_state(self.current_state, char)
  end

  def read_string(string)
    string.chars.each do |char|
      read_char(char)
    end
  end
end

class DFADesign < Struct.new(:start_state, :accept_states, :rule_book)
  def to_dfa
    DFA.new(start_state, accept_states, rule_book)
  end

  def accepts?(string)
    to_dfa.tap {|dfa| dfa.read_string(string)}.accepting?
  end
end

class NFARulebook < Struct.new(:rules)
  # since each state returns an enumerable
  # flat_map returns a new flat sequence
  def next_states(states, char)
    states.flat_map { |state|
      follow_rules_for(state, char)
    }.to_set
  end

  def follow_rules_for(state, char)
    rules_for(state, char).map(&:follow)
  end

  def rules_for(state, char)
    rules.select { |rule| rule.applies_to?(state, char) }
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rule_book)
  def accepting?
    (current_states & accept_states).any?
  end

  def read_char(char)
    self.current_states = rule_book.next_states(current_states, char)
  end

  def read_string(string)
    string.chars.each do |char|
      read_char(char)
    end
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rule_book)
  def to_nfa
    NFA.new(Set[start_state], accept_states, rule_book)
  end

  def accepts?(string)
    to_nfa.tap {|nfa| nfa.read_string(string)}.accepting?
  end
end

# example -- third-from-last character is 'b'
# rulebook = NFARulebook.new([
#       FARule.new(1, 'a', 1),
#       FARule.new(1, 'b', 1),
#       FARule.new(1, 'b', 2),
#       FARule.new(2, 'a', 3),
#       FARule.new(2, 'b', 3),
#       FARule.new(3, 'a', 4),
#       FARule.new(3, 'b', 4)])
# nfa = NFADesign.new(1, [4], rulebook)
# nfa.accepts?('ba')
# -> false
# nfa.accepts?('baa')
# -> true
