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

  describe DTM do
    before :all do
      @conf = TMConfiguration.new(1, Tape.new([], '0', [], '_'))
      @stuck_conf = TMConfiguration.new(1, Tape.new(['1', '2', '1'], '1', [], '_'))
      @rulebook = DTMRulebook.new([
                                   TMRule.new(1, '0', 2, '1', :right),
                                   TMRule.new(1, '1', 1, '0', :left),
                                   TMRule.new(1, '_', 2, '1', :right),
                                   TMRule.new(2, '0', 2, '0', :right),
                                   TMRule.new(2, '1', 2, '1', :right),
                                   TMRule.new(2, '_', 3, '_', :left)
                                  ])
      @dtm = DTM.new(@conf, [3], @rulebook)
      @stuck_dtm = DTM.new(@stuck_conf, [3], @rulebook)

      repeat_abc_rulebook =
        DTMRulebook.new([
                         # state 1: scan right looking for a
                         TMRule.new(1, 'X', 1, 'X', :right), # skip X
                         TMRule.new(1, 'a', 2, 'X', :right), # cross out a, go to state 2
                         TMRule.new(1, '_', 6, '_', :left),  # find blank, go to state 6 (accept)

                         # state 2: scan right looking for b
                         TMRule.new(2, 'a', 2, 'a', :right), # skip a
                         TMRule.new(2, 'X', 2, 'X', :right), # skip X
                         TMRule.new(2, 'b', 3, 'X', :right), # cross out b, go to state 3

                         # state 3: scan right looking for c
                         TMRule.new(3, 'b', 3, 'b', :right), # skip b
                         TMRule.new(3, 'X', 3, 'X', :right), # skip X
                         TMRule.new(3, 'c', 4, 'X', :right), # cross out c, go to state 4

                         # state 4: scan right looking for end of string
                         TMRule.new(4, 'c', 4, 'c', :right), # skip c
                         TMRule.new(4, '_', 5, '_', :left),  # find blank, go to state 5

                         # state 5: scan left looking for beginning of string
                         TMRule.new(5, 'a', 5, 'a', :left),  # skip a
                         TMRule.new(5, 'b', 5, 'b', :left),  # skip b
                         TMRule.new(5, 'c', 5, 'c', :left),  # skip c
                         TMRule.new(5, 'X', 5, 'X', :left),  # skip X
                         TMRule.new(5, '_', 1, '_', :right)  # find blank, go to state 1
                        ])
      repeat_abc_tape = Tape.new([], 'a', ['a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'], '_')
      @aaabbbccc = DTM.new(TMConfiguration.new(1, repeat_abc_tape), [6], repeat_abc_rulebook)
    end
    
    describe "#next_configuration" do
      it "gets next configuration" do
        next_conf = @rulebook.next_configuration(@conf)
        expect(next_conf.state).to eq(2)
        expect(next_conf.tape.middle).to eq('_')
        expect(next_conf.tape.left).to eq(['1'])
        expect(next_conf.tape.right).to eq([])
      end
    end
    describe "#run" do
      it "runs to accepted state" do
        @dtm.run
        expect(@dtm.accepting?).to be true
      end
      it "runs to stuck state" do
        @stuck_dtm.run
        expect(@stuck_dtm.accepting?).to be false
        expect(@stuck_dtm.stuck?).to be true
      end
      it "runs aaabbbccc pattern" do
        @aaabbbccc.run
        expect(@aaabbbccc.accepting?).to be true
      end
    end
  end
end
