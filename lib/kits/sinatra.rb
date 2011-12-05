# Extends sinatra as a Kits-provider

module Sinatra
  module PartsKit

    def self.registered(app)
      app.set :kit, Kits::Kit.new
      self.load_components(app)
      app.get "/components" do
        settings.kit.as_json.to_json
      end
      app.set :kit_sprockets, Kits::Sprockets::Environment.new(app.root, app.kit)
      app.get "/components/assets/:asset" do |asset|
        env["PATH_INFO"] = "/#{asset}"
        settings.kit_sprockets.call(env)
      end
    end

    private

    def self.load_components(app)
      Dir.glob(app.root+'/**/*.part.rb').each do |file_name|
        component = app.kit.load_component(file_name)
        app.get("/components/#{component.name}", {}, &component.action) if component.action 
      end
    end

  end

  register PartsKit
end