class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      Add.new(left.reduce(env), right)
    elsif right.reducible?
      Add.new(left, right.reduce(env))
    else
      Number.new(left.value + right.value)
    end
  end
end

class Minus < Struct.new(:left, :right)
  def to_s
    "#{left} - #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      Minus.new(left.reduce(env), right)
    elsif right.reducible?
      Minus.new(left, right.reduce(env))
    else
      Number.new(left.value - right.value)
    end
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      Multiply.new(left.reduce(env), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(env))
    else
      Number.new(left.value * right.value)
    end
  end
end

class Divide < Struct.new(:left, :right)
  def to_s
    "#{left} / #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      Divide.new(left.reduce(env), right)
    elsif right.reducible?
      Divide.new(left, right.reduce(env))
    else # TODO: raise error if right.value == 0
      Number.new(left.value / right.value)
    end
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    false
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      LessThan.new(left.reduce(env), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(env))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    env[name]
  end
end

class DoNothing
  def to_s
    "Do nothing"
  end

  def inspect
    "<<#{self}>>"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if expression.reducible?
      [Assign.new(name, expression.reduce(env)), env]
    else
      [DoNothing.new, env.merge({name => expression})]
    end
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if condition.reducible?
      [If.new(condition.reduce(env), consequence, alternative), env]
    elsif condition == Boolean.new(true)
      [consequence, env]
    else
      [alternative, env]
    end
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if first == DoNothing.new
      [second, env]
    else
      new_first, new_env = first.reduce(env)
      [Sequence.new(new_first, second), new_env]
    end
  end
end

class While < Struct.new(:cond, :body)
  def to_s
    "while(#{cond}) { #{body} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    [If.new(cond,
            Sequence.new(body, self),
            DoNothing.new),
     env]
  end
end

class Machine < Struct.new(:statement, :env)
  def step
    self.statement, self.env = statement.reduce(env)
  end

  def run
    while statement.reducible?
      puts "#{statement}, #{env}"
      step
    end
    puts "#{statement}, #{env}"
  end
end
