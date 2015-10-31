require 'spec_helper'

describe "Deterministic PushDown Automata" do

  before :all do
    # balanced parentheses
    rulebook = DPDARulebook.new([
                                 PDARule.new(1, '(', 2, '$', ['b', '$']),
                                 PDARule.new(2, '(', 2, 'b', ['b', 'b']),
                                 PDARule.new(2, ')', 2, 'b', []),
                                 PDARule.new(2, nil, 1, '$', ['$'])])
    @dpda_design = DPDADesign.new(1, '$', [1], rulebook)
  end

  describe "#accepting?" do
    it "accepts '(((((((((())))))))))'" do
      expect(@dpda_design.accepts?('(((((((((())))))))))')).to be true
    end
    it "accepts '()(())((()))(()(()))'" do
      expect(@dpda_design.accepts?('()(())((()))(()(()))')).to be true
    end
    it "doesn't accept '(()(()(()()(()()))()'" do
      expect(@dpda_design.accepts?('(()(()(()()(()()))()')).to be false
    end
  end
end

describe "Non-deterministic PushDown Automata" do

  before :all do
    # palindromes made up of char 'a' and 'b'
    rulebook = NPDARulebook.new([
                                 PDARule.new(1, 'a', 1, '$', ['a', '$']),
                                 PDARule.new(1, 'a', 1, 'a', ['a', 'a']),
                                 PDARule.new(1, 'a', 1, 'b', ['a', 'b']),
                                 PDARule.new(1, 'b', 1, '$', ['b', '$']),
                                 PDARule.new(1, 'b', 1, 'a', ['b', 'a']),
                                 PDARule.new(1, 'b', 1, 'b', ['b', 'b']),
                                 PDARule.new(1, nil, 2, '$', ['$']),
                                 PDARule.new(1, nil, 2, 'a', ['a']),
                                 PDARule.new(1, nil, 2, 'b', ['b']),
                                 PDARule.new(2, 'a', 2, 'a', []),
                                 PDARule.new(2, 'b', 2, 'b', []),
                                 PDARule.new(2, nil, 3, '$', ['$'])])
    @npda_design = NPDADesign.new(1, '$', [3], rulebook)
  end

  describe "#accepts?" do
    it "accepts 'abba'" do
      expect(@npda_design.accepts?('abba')).to be true
    end
    it "accepts 'babbaabbab'" do
      expect(@npda_design.accepts?('babbaabbab')).to be true
    end
    it "doesn't accept 'abb'" do
      expect(@npda_design.accepts?('abb')).to be false
    end
    it "doesn't accept 'baabaa'" do
      expect(@npda_design.accepts?('baabaa')).to be false
    end
  end
end
