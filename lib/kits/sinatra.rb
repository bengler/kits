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
      app.kit.templates.each do |path|
        template_key =  File.basename(path).scan(/^[^\.]+/).first.to_sym
        $stderr.puts "Warning: A template named #{template_key} defined more than once." if app.templates[template_key]
        content = File.read(path)
        app.template(template_key) { content }
      end
      app.get "/parts/client_templates" do
        @embeddable_client_template_html ||= 
          Kits::ClientTemplates.new(
            Sinatra::PartsKit.discover_service_name(env['PATH_INFO']),
            app.kit.templates, 
            app.kit_sprockets).generate
      end
    end

    def self.discover_service_name(http_path)
      /^\/api\/(?<service>[^\/]+)\/v\d+/ =~ http_path
      service || 'example'
    end
  end
end