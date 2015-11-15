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
