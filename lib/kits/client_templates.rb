# A class to generate client side template sheets
require "json"

class Kits::ClientTemplates
  attr_reader :template_files
  CLIENT_TEMPLATE_RECOGNIZER = /\.mustache|\.fu$/

  def initialize(service_name, files, sprockets = nil)
    @service_name = service_name
    @template_files = files.select{ |path| path =~ CLIENT_TEMPLATE_RECOGNIZER }
    @sprockets = sprockets
  end

  def generate
    templates = Hash[@template_files.map {|path|
        template = grab_template(path)
        [template[:name], template[:body]]
      }]
    "define('#{@service_name}/parts/templates', #{templates.to_json})"
  end

  def grab_template(path)
    result = {:name => self.class.template_name(path), :type => self.class.template_type(path),
              :body => template_body(path)}
    # Fu-templates are automatically converted to mustache.              
    if result[:type] == 'fu'
      raise "You must install and require 'fu' to use fu templates (#{path})" unless defined?(Fu)
      result[:body] = Fu.to_mustache(result[:body])
      result[:type] = 'mustache'
    end
    result
  end

  private

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
