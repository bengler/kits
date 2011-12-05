require 'set'
require 'sinatra'

class Kits::Kit
  attr_reader :components

  def initialize
    @components = {}
  end

  def load_component(definition_file)
    component = Kits::Component.load(self, definition_file)
    @components[component.name] = component
    component
  end

  # The asset paths for every component
  def asset_paths
    @components.values.map(&:asset_path).compact.uniq
  end

  # The main javascript for every component
  def scripts
    @components.values.map(&:script).compact
  end

  # The main css for every component
  def stylesheets
    @components.values.map(&:stylesheet).compact
  end

  def as_json
    Hash[@components.map {|k, v| [k, v.as_json]}]
  end

end
