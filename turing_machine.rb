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

class TMRule < Struct.new(:state, :char, :next_state, :write_char, :direction)
  def applies_to?(configuration)
    state == configuration.state &&
      char == configuration.tape.middle
  end

  def follow(configuration)
    if applies_to?(configuration)
      TMConfiguration.new(next_state, next_tape(configuration))
    end
  end

  def next_tape(configuration)
    tw = configuration.tape.write(write_char)
    case direction
    when :left
      tw.move_head_left
    when :right
      tw.move_head_right
    end
  end
end

class DTMRulebook < Struct.new(:rules)
  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def applies_to?(configuration)
    !rule_for(configuration).nil?
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def stuck?
    !accepting? &&
      !rulebook.applies_to?(current_configuration)
  end

  def step
    self.current_configuration =
      rulebook.next_configuration(current_configuration)
  end

  def run
    step until accepting? || stuck?
  end
end
