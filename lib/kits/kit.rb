require 'set'
require 'sinatra'

class Kits::Kit
  attr_reader :parts, :root

  def initialize(root)
    @root = root
    @parts = {}
  end

  def load_part(definition_file)
    part = Kits::Part.load(definition_file)
    @parts[part.name] = part
    part
  end

  # The asset paths for every part
  def asset_paths
    paths = @parts.values.map(&:asset_path)
    paths << File.dirname(script) if script
    paths << File.dirname(stylesheet) if stylesheet
    paths.compact.uniq
  end

  # Locate the common parts.js
  def script
    @script ||= (Dir.glob(root+'/**/parts.js').first || Dir.glob(root+'/**/parts.js.coffee').first)
  end

  # Locate the common parts.css
  def stylesheet
    @stylesheet ||= Dir.glob(root+'/**/parts.*css').first
  end

  # The main javascript for every part
  def scripts
    @parts.values.map(&:script).compact
  end

  # The main css for every part
  def stylesheets
    @parts.values.map(&:stylesheet).compact
  end

  def as_json
    Hash[@parts.map {|k, v| [k, v.as_json]}]
  end

end
