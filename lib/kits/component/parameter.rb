class Kits::Component::Parameter
  attr_accessor :name, :description

  def initialize(name, options)
    @name = name
    @description = options[:description]
    @required = options[:required]
  end

  def required?
    @required
  end

  def as_json
    {:name => @name, :description => @description}
  end
end
