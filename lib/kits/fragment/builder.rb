class Kits::Fragment::Builder
  attr_reader :fragment

  def initialize(fragment)
    @fragment = fragment
  end

  def title(title)
    @fragment.title = title
  end

  def description(description)
    @fragment.description = description
  end

  def param(name, description, options)
    @fragment.parameters[name.to_s] = Parameter.new(name, {:description => description}.merge(options))
  end

  def action(&block)
    @fragment.action = block
  end
end
