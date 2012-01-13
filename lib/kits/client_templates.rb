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

  def generate_amd
    "define('#{@service_name}/parts/templates', #{read_templates.to_json})"
  end

  def generate_html
    read_templates.map do |name, template|
      "<script data-template-name=\"#{@service_name}.#{name}\" data-template-language=\"#{template[:type]}\" type=\"text/html\">#{template[:body]}</script>"
    end.join
  end

  def generate_json
    read_templates.to_json
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

  def read_templates
    Hash[@template_files.map {|path|
      template = grab_template(path)
      [template[:name], template]
    }]
  end

  def self.template_name(path)
    File.basename(path).scan(/^[^\.]+/).first.to_sym
  end

  def self.template_type(path)
    File.basename(path).scan(/(?:\.)([^\.]+)$/).flatten.first
  end

  def template_body(path)
    asset = @sprockets.find_asset(File.basename(path))
    body = asset.body if asset
    body = File.read(path)
    body.force_encoding("UTF-8")
  end
end
