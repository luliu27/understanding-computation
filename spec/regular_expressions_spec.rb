require 'spec_helper'

describe "Regular Expressions" do

  before :all do
    # generate pattern /(a|bc)*/
    @pattern = Repeat.new(
                 Choose.new(Literal.new('a'),
                   Concatenate.new(Literal.new('b'), Literal.new('c'))))
  end

  describe "#matches?" do
    it "matches 'aaaa'" do
      expect(@pattern.matches?('aaaa')).to be true
    end
    it "doesn't match 'abababab'" do
      expect(@pattern.matches?('abababab')).to be false
    end
    it "matches 'bcbc'" do
      expect(@pattern.matches?('bcbc')).to be true
    end
    it "doesn't match 'bcb'" do
      expect(@pattern.matches?('bcb')).to be false
    end
    it "matches 'bca'" do
      expect(@pattern.matches?('bca')).to be true
    end
  end
end
