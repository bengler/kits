class Kits::Fragment::Parameter
  attr_accessor :name, :description, :title

  def initialize(name, options)
    @name = name
    @description = options[:description]
    @required = options[:required]
  end

  def required?
    @required
  end
end
