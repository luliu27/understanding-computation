class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    self
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    self
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

  def evaluate(env)
    env
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    env[name]
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    Number.new(left.evaluate(env).value +
               right.evaluate(env).value)
  end
end

class Minus < Struct.new(:left, :right)
  def to_s
    "#{left} - #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    Number.new(left.evaluate(env).value -
               right.evaluate(env).value)
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    Number.new(left.evaluate(env).value *
               right.evaluate(env).value)
  end
end

class Divide < Struct.new(:left, :right)
  def to_s
    "#{left} / #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    Number.new(left.evaluate(env).value /
               right.evaluate(env).value)
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    Boolean.new(left.evaluate(env).value <
                right.evaluate(env).value)
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    env.merge({ name => expression.evaluate(env) })
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    case condition.evaluate(env)
    when Boolean.new(true)
      consequence.evaluate(env)
    when Boolean.new(false)
      alternative.evaluate(env)
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

  def evaluate(env)
    second.evaluate(first.evaluate(env))
  end
end

class While < Struct.new(:cond, :body)
  def to_s
    "while(#{cond}) { #{body} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(env)
    case cond.evaluate(env)
    when Boolean.new(true)
      evaluate(body.evaluate(env))
    when Boolean.new(false)
      env
    end
  end
end
