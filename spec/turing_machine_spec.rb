require 'spec_helper'

describe Tape do

  before :all do
    @tape = Tape.new(['1', '0', '1'], '1', [], '_')
  end

  describe "#write" do
    it "writes '2' to the middle" do
      tw = @tape.write('2')
      expect(tw.middle).to eq('2')
      expect(tw.left).to eq(['1', '0', '1'])
      expect(tw.right).to eq([])
    end
  end

  describe "#move_head_left" do
    it "moves head to left" do
      hl = @tape.move_head_left
      expect(hl.middle).to eq('1')
      expect(hl.left).to eq(['1', '0'])
      expect(hl.right).to eq(['1'])
    end
  end

  describe "#move_head_right" do
    it "moves head to right" do
      hr = @tape.move_head_right
      expect(hr.middle).to eq('_')
      expect(hr.left).to eq(['1', '0', '1', '1'])
      expect(hr.right).to eq([])
    end
  end
end

describe TMRule do
  before :all do
    @tm_rule = TMRule.new(1, '0', 2, '1', :left)
    @conf1 = TMConfiguration.new(1, Tape.new(['1', '0'], '0', [], '_'))
    @conf2 = TMConfiguration.new(1, Tape.new(['1', '0'], '1', [], '_'))
  end

  describe "#applies_to?" do
    it "applies to tape and state" do
        expect(@tm_rule.applies_to?(@conf1)).to be true
    end
    it "doesn't apply to tape and state" do
        expect(@tm_rule.applies_to?(@conf2)).to be false
    end
    it "follows configuration" do
      next_conf1 = @tm_rule.follow(@conf1)
      expect(next_conf1.state).to eq(2)
      expect(next_conf1.tape.middle).to eq('0')
      expect(next_conf1.tape.left).to eq(['1'])
      expect(next_conf1.tape.right).to eq(['1'])
    end
  end
end
