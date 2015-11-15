# the ultimate machine -- Turing machine

class Tape < Struct.new(:left, :middle, :right, :blank)
  def inspect
    "#<tape #{left} #{middle} #{right} #{blank}>"
  end

  def write(char)
    Tape.new(left, char, right, blank)
  end

  def move_head_left
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end

  def move_head_right
    Tape.new(left + [middle], right.first || blank, right.drop(1), blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :next_state)
end

class TMRulebook < Struct.new(:rules)
end

class TM < Struct.new(:current_configuation, :accept_states, :rulebook)
end

class TMDesign < Struct.new(:start_state, :accept_states, :rulebook)
end
