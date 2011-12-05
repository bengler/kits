require 'spec_helper'
require 'json'

class KitApp < Sinatra::Base
  set :root, File.dirname(__FILE__)+"/fixtures"
  register Sinatra::PartsKit
end

describe "API v1 posts" do
  include Rack::Test::Methods

  def app
    KitApp
  end

  it "Knows where to look for assets" do
    app.kit.asset_paths.sort[0].should =~ /\/parts$/
    app.kit.asset_paths.sort[1].should =~ /\/parts\/demo$/
    app.kit.components['demo'].script.should =~ /\/demo\/demo\.js\.coffee$/
    app.kit.components['withcss'].stylesheet.should =~ /\/withcss\.css$/
  end

  it "Has a kit property" do
    app.kit.should_not be_nil
    app.kit.components.keys.sort.should eq ['demo', 'other', 'withcss'].sort
  end

  it "Presents the registered components" do
    get "/components"
    result = JSON.parse(last_response.body)
    result['demo']['component'].keys.sort.should eq ['name', 'title', 'description', 'parameters', 'preloadable'].sort
    result['demo']['component']['parameters'].map{|p| p['name']}.sort.should eq ['param_1', 'param_2'].sort
  end

  it "Provides a component called demo" do
    get "/components/demo"
    last_response.body.should eq "Hello world"
  end

  it "Presents itself as preloadable since it has a server side implementation" do
    get "/components"
    result = JSON.parse(last_response.body)
    result['demo']['component']['preloadable'].should be_true
  end

  it "Implements a special directive to require all component javascripts" do
    get "/components/assets/parts.js"
    last_response.body.should =~ /Hello from coffeescript/
    get "/components/assets/parts.css"
    last_response.body.should =~ /hello\.from\.css/
  end

end