# Extends sinatra as a Kits-provider

module Sinatra
  module PartsKit

    def self.registered(app)
      app.set :kit, Kits::Kit.new(app.root+"/parts")
      load_parts(app)
      publish_assets(app)
      register_templates(app)
    end

    private

    def self.load_parts(app)
      Dir.glob(app.kit.root+'/**/*.part.rb').each do |file_name|
        part = app.kit.load_part(file_name)
        app.get("/parts/#{part.name}", {}, &part.action) if part.action 
      end
      # Publish parts-registry api-call
      app.get "/parts" do
        settings.kit.as_json.to_json
      end
    end

    def self.publish_assets(app)
      app.set :kit_sprockets, Kits::Sprockets::Environment.new(app.root, app.kit)
      app.get "/parts/assets/:asset" do |asset|
        env["PATH_INFO"] = "/#{asset}"
        settings.kit_sprockets.call(env)
      end
    end

    def self.register_templates(app)
      # Register all templates
      Tilt.mappings.each do |ext, engines|
        next unless engines.map(&:default_mime_type).include?('text/html')
        Dir.glob(app.kit.root+"/**/*.#{ext}").each do |path|
          template_key =  File.basename(path).scan(/^[^\.]+/).first.to_sym
          $stderr.puts "Warning: A template named #{template_key} defined more than once." if app.templates[template_key]
          content = File.read(path)
          app.template(template_key) { content }
        end
      end
    end

  end

  register PartsKit
end