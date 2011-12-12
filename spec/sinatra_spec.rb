require 'spec_helper'
require 'json'
require 'kits/sinatra'
require 'fu/tilt'

class KitApp < Sinatra::Base
  set :root, File.dirname(__FILE__)+"/fixtures"  
  set :service_name, 'example'
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
    app.kit.parts['demo'].script.should =~ /\/demo\/demo\.js\.coffee$/
    app.kit.parts['withcss'].stylesheet.should =~ /\/withcss\.css$/
  end

  it "Has a kit property" do
    app.kit.should_not be_nil
    app.kit.parts.keys.sort.should eq ['demo', 'other', 'withcss', 'hamlpart', 'mustachepart', 'fupart'].sort
  end

  it "Presents the registered parts" do
    get "/parts"
    result = JSON.parse(last_response.body)
    result['demo']['part'].keys.sort.should eq ['name', 'title', 'description', 'parameters', 'preloadable'].sort
    result['demo']['part']['parameters'].map{|p| p['name']}.sort.should eq ['param_1', 'param_2'].sort
  end

  it "Provides a part called demo" do
    get "/parts/demo"
    last_response.body.should eq "Hello world"
  end

  it "Presents itself as preloadable since it has a server side implementation" do
    get "/parts"
    result = JSON.parse(last_response.body)
    result['demo']['part']['preloadable'].should be_true
  end

  it "Implements a special directive to require all part javascripts" do
    get "/parts/assets/parts.js"
    last_response.body.should =~ /Hello from coffeescript/
    get "/parts/assets/parts.css"
    last_response.body.should =~ /hello\.from\.css/
  end

  it "has discovered html templates (but not js-templates)" do
    app.templates.keys.should include :hamlpart
    app.templates.keys.should_not include :demo
  end

  it "can render a template" do
    get "/parts/hamlpart"
    last_response.body.should_not =~ /application\serror/
    last_response.body.should =~ /Hello from haml/
  end

  it "locates client side templates and builds a bundle" do
    get "/parts/client_templates"
    last_response.body.should_not =~ /application\serror/
    last_response.body.should =~ /Hello from \{\{mustache\}\}/
    last_response.body.should =~ /mustachetemplate/    
  end

  it "packages fu-templates with the client_templates converted to mustache" do
    get "/parts/client_templates"
    last_response.body.should_not =~ /application\serror/
    last_response.body.should =~ /\<p\>Hello from fu\!\<\/p\>/
  end

  it "can render mustache templates on the server too" do
    get "/parts/mustachepart"
    last_response.body.should_not =~ /application\serror/
    last_response.body.should_not =~ /\{\{mustache\}\}/
    last_response.body.should =~ /Hello from data/
  end
end
