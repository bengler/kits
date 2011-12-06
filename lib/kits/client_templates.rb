# A class to generate client side template sheets

class Kits::ClientTemplates
  attr_reader :template_files
  CLIENT_TEMPLATE_RECOGNIZER = /\.mustache$/

  def initialize(service_name, files, sprockets = nil)
    @namespace = service_name
    @template_files = files.select{ |path| path =~ CLIENT_TEMPLATE_RECOGNIZER }
    @sprockets = sprockets
  end

  def generate
    result = []
    @template_files.map do |path|
      name = self.class.template_name(path)
      type = self.class.template_type(path)
      "<script data-template-name=\"#{@namespace}.#{name}\" data-template-language=\"#{type}\" type=\"text/html\">#{template_body(path)}</script>"
    end.join
  end

  def self.template_name(path)
    File.basename(path).scan(/^[^\.]+/).first.to_sym
  end

  def self.template_type(path)
    File.basename(path).scan(/(?:\.)([^\.]+)$/).flatten.first
  end

  def template_body(path)
    asset = @sprockets.find_asset(File.basename(path))
    return asset.body if asset
    File.read(path)
  end
end
