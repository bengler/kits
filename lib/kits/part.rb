class Kits::Part
  attr_accessor :kit, :title, :description, :name, :parameters, :action, :definition_file

  def initialize(kit, name)
    @kit = kit
    @name = name
    @parameters = {}
  end

  def self.load(kit, definition_file)    
    /(?<name>.*).part.rb$/ =~ File.basename(definition_file)
    raise ArgumentError, "A part definition must end in '.part.rb'" unless name
    builder = Builder.new(Kits::Part.new(kit, name))
    builder.instance_eval(File.read(definition_file), definition_file)
    builder.part.definition_file = definition_file
    builder.part
  end

  def asset_path
    @asset_path ||= File.dirname(definition_file)
  end

  def script
    @script ||= locate_file(@name, ['js', 'js.coffee'])
  end

  def stylesheet
    @stylesheet ||= locate_file(@name, ['css', 'scss', 'sass'])
  end

  def as_json
    {:part => {
      :name => @name, :title => @title, :description => @description, 
      :parameters => @parameters.values.map(&:as_json),
      :preloadable => !@action.nil?}}
  end

  private

  def locate_file(basename, extensions)
    return nil unless asset_path
    extensions.each do |extension|
      expanded = "#{asset_path}/#{basename}.#{extension}"
      return expanded if File.exist?(expanded)
    end
    nil
  end

end
