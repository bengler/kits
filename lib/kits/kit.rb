require 'set'
require 'sinatra'

class Kits::Kit
  attr_reader :parts

  def initialize
    @parts = {}
  end

  def load_part(definition_file)
    part = Kits::Part.load(self, definition_file)
    @parts[part.name] = part
    part
  end

  # The asset paths for every part
  def asset_paths
    @parts.values.map(&:asset_path).compact.uniq
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
