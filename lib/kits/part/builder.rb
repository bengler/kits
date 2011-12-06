class Kits::Part::Builder
  attr_reader :parts

  def initialize(definition_file = nil)
    @parts = []
    @definition_file = definition_file
  end

  def part(name, &block)
    part_builder = PartBuilder.new(Kits::Part.new(name.to_s))
    part_builder.instance_eval(&block)
    part_builder.part.definition_file = @definition_file
    @parts << part_builder.part
    part_builder.part
  end

  class PartBuilder
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
end