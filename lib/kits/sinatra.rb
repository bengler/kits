# Extends sinatra as a Kits-provider

module Sinatra
  module PartsKit

    def self.registered(app)
      app.set :kit, Kits::Kit.new
      self.load_parts(app)
      app.get "/parts" do
        settings.kit.as_json.to_json
      end
      app.set :kit_sprockets, Kits::Sprockets::Environment.new(app.root, app.kit)
      app.get "/parts/assets/:asset" do |asset|
        env["PATH_INFO"] = "/#{asset}"
        settings.kit_sprockets.call(env)
      end
    end

    private

    def self.load_parts(app)
      Dir.glob(app.root+'/**/*.part.rb').each do |file_name|
        part = app.kit.load_part(file_name)
        app.get("/parts/#{part.name}", {}, &part.action) if part.action 
      end
    end

  end

  register PartsKit
end