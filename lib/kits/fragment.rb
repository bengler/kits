class Kits::Fragment
  attr_accessor :kit, :title, :description, :name, :parameters, :action

  def initialize(kit, name)
    @kit = kit
    @name = name
    @parameters = {}
  end

  def self.define(kit, name, &block)
    builder = Builder.new(Kits::Fragment.new(kit, name))
    builder.instance_eval(&block)
    builder.fragment
  end
end
