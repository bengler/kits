class Kits::Component::Builder
  attr_reader :component

  def initialize(component)
    @component = component
  end

  def title(title)
    @component.title = title
  end

  def description(description)
    @component.description = description
  end

  def param(name, description, options = {})
    @component.parameters[name.to_s] = Kits::Component::Parameter.new(name, {:description => description}.merge(options))
  end

  def action(&block)
    @component.action = block
  end
end
