require 'spec_helper'

describe DFADesign do

  before :all do
    @rulebook = DFARulebook.new([
          FARule.new(1, 'a', 2),
          FARule.new(1, 'b', 1),
          FARule.new(2, 'a', 2),
          FARule.new(2, 'b', 3),
          FARule.new(2, 'b', 3),
          FARule.new(3, 'a', 3),
          FARule.new(3, 'b', 3)])
    @dfa_design = DFADesign.new(1, [3], @rulebook)
  end

  describe "#accepts?" do
    it "doesn't accept 'a'" do
      expect(@dfa_design.accepts?('a')).to be false
    end
    it "doesn't accept 'baa'" do
      expect(@dfa_design.accepts?('baa')).to be false
    end
    it "accepts 'baba'" do
      expect(@dfa_design.accepts?('baba')).to be true
    end
  end
end

describe NFADesign do

  before :all do
    # third-from-last char is 'b'
    @rulebook = NFARulebook.new([
        FARule.new(1, 'a', 1),
        FARule.new(1, 'b', 1),
        FARule.new(1, 'b', 2),
        FARule.new(2, 'a', 3),
        FARule.new(2, 'b', 3),
        FARule.new(3, 'a', 4),
        FARule.new(3, 'b', 4)])
    @nfa_design = NFADesign.new(1, [4], @rulebook)
    # multiple of two or three letters with free move
    @rulebook_freemove = NFARulebook.new([
      FARule.new(1, nil, 2),
      FARule.new(1, nil, 4),
      FARule.new(2, 'a', 3),
      FARule.new(3, 'a', 2),
      FARule.new(4, 'a', 5),
      FARule.new(5, 'a', 6),
      FARule.new(6, 'a', 4)])
    @nfa_freemove = NFADesign.new(1, [2,4], @rulebook_freemove)
  end

  describe "#accepts?" do
    it "doesn't accept 'ba'" do
      expect(@nfa_design.accepts?('ba')).to be false
    end
    it "accepts 'baa'" do
      expect(@nfa_design.accepts?('baa')).to be true
    end
    it "doesn't accept 'a'" do
      expect(@nfa_freemove.accepts?('a')).to be false
    end
    it "accepts 'aa'" do
      expect(@nfa_freemove.accepts?('aa')).to be true
    end
    it "accepts 'aaa'" do
      expect(@nfa_freemove.accepts?('aaa')).to be true
    end
    it "accepts 'aaaa'" do
      expect(@nfa_freemove.accepts?('aaaa')).to be true
    end
     it "doesn't accept 'aaaaa'" do
      expect(@nfa_freemove.accepts?('aaaaa')).to be false
    end
  end
end
