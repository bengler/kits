class Kits::Part::Builder
  attr_reader :part

  def initialize(part)
    @part = part
  end

  def title(title)
    @part.title = title
  end

  def description(description)
    @part.description = description
  end

  def param(name, description, options = {})
    @part.parameters[name.to_s] = Kits::Part::Parameter.new(name, {:description => description}.merge(options))
  end

  def action(&block)
    @part.action = block
  end
end
