require_relative 'fa_rulebook'

# we provide following regular expressions:
# empty
# literal: a
# concatenate: ab
# choose: a|b
# repeat: a*
# for the concrete syntax of re, precedence bindings are follows:
# repeat > concatenate > choose
module Pattern
  def bracket(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else
      to_s
    end
  end

  def inspect
    "/#{self}/"
  end

  def matches?(string)
    to_nfa_design.accepts?(string)
  end
end

class Empty
  include Pattern

  def to_s
    ''
  end

  def precedence
    3
  end

  def to_nfa_design
    start_state = Object.new
    accept_states = [start_state]
    rule_book = NFARulebook.new([])
    NFADesign.new(start_state, accept_states, rule_book)
  end
end

class Literal < Struct.new(:char)
  include Pattern

  def to_s
    char
  end

  def precedence
    3
  end

  def to_nfa_design
    start_state = Object.new
    accept_state = Object.new
    rule = FARule.new(start_state, self.char, accept_state)
    rule_book = NFARulebook.new([rule])
    NFADesign.new(start_state, [accept_state], rule_book)
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join
  end

  def precedence
    1
  end

  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design
    start_state = first_nfa_design.start_state
    accept_states = second_nfa_design.accept_states
    rules = first_nfa_design.rule_book.rules +
            second_nfa_design.rule_book.rules
    additional_rules = first_nfa_design.accept_states.map { |state|
      FARule.new(state, nil, second_nfa_design.start_state) }
    rule_book = NFARulebook.new(rules + additional_rules)
    NFADesign.new(start_state, accept_states, rule_book)
  end 
end

class Choose < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join('|')
  end

  def precedence
    0
  end

  def to_nfa_design
    start_state = Object.new
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design
    accept_states = first_nfa_design.accept_states +
                    second_nfa_design.accept_states
    rules = first_nfa_design.rule_book.rules +
            second_nfa_design.rule_book.rules
    additional_rules = [ FARule.new(start_state, nil, first_nfa_design.start_state),
                         FARule.new(start_state, nil, second_nfa_design.start_state) ]
    rule_book = NFARulebook.new(rules + additional_rules)
    NFADesign.new(start_state, accept_states, rule_book)
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern

  def to_s
    pattern.bracket(precedence) + "*"
  end

  def precedence
    2
  end

  def to_nfa_design
    pattern_nfa_design = pattern.to_nfa_design
    start_state = Object.new
    accept_states = [start_state] + # match zero
                    pattern_nfa_design.accept_states
    rules = pattern_nfa_design.rule_book.rules +
            pattern_nfa_design.accept_states.map { |state|
              FARule.new(state, nil, pattern_nfa_design.start_state) } +
            [FARule.new(start_state, nil, pattern_nfa_design.start_state)]
    rule_book = NFARulebook.new(rules)
    NFADesign.new(start_state, accept_states, rule_book)
  end
end

# example:
# pattern = Repeat.new(
#             Choose.new(Literal.new('a'),
#               Concatenate.new(Literal.new('b'), Literal.new('c'))))
# => /(a|bc)*/ 
# pattern.matches?('aaaa')
# => true 
# pattern.matches?('abababab')
# => false 
# pattern.matches?('bcbc')
# => true 
# pattern.matches?('bcb')
# => false 
# pattern.matches?('bca')
# => true 
