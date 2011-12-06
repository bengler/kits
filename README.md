# Kits

Kits is a Sinatra extension that makes it easy to provide Pebbles frontend parts.

# Installation

Stick this in you Gemfile:
   
    gem "kits", :git => 'git@github.com:benglerpebbles/kits.git'

# Usage

## Files

Define your parts in the folder "/parts" under your application root folder. It is recommended that you make a 
folder for each part and keep all scripts, stylesheets and views related to your part there. E.g:

    /parts/my_part
    /parts/my_part/my_part.part.rb      # part definition
    /parts/my_part/my_part.js.coffee    # main javascript file
    /parts/my_part/my_part.scss         # main stylesheet
    /parts/my_part/my_part.mustache     # a template

Kits uses Sprockets to process assets and every part-folder is added to the search path. Thus you can put any
auxillary scripts, views or templates in your part folder and expect them to be served to clients. There is one
gotcha however: *Sprockets and Sinatra uses a flat namespace for templates and assets, so no two templates or
other assets may have the same file name even if they reside in separate folders.*

Additionally you need to add the common script file, and stylesheet here:

    /parts/parts.js.coffee              # You don't HAVE to use coffeescript, but you should
    /parts/parts.scss                   # You could use css

The common assets will be the ones that clients include and should provide all scripts/stylesheets for the entire
kit. A special sprocets directive is provided to do this automatically:

    // Put this line in the top of both parts.js and parts.css
    //= require_parts

You can require or include any other common scripts or stylesheets you need in these files.

## Parts definitions

Every part needs a definition in the form of a .part.rb-file. It is executed as a common ruby file with the parts
definition DSL provided. A typical part definition file could look like this:

    part :blog_post do
      title "Blog post"
      description "Renders a blog post"
      param :id, "Id of the blog post"
      param :style, "Style, one of: 'compact', 'normal', 'expanded'. Default is 'normal'"

      action do
        post = BlogPost.find(params[:id])
        mustache :blog_post, :locals => { :post => post.attributes }
      end
    end

The `action` part of the definition indicates that the part supports server side rendering and is mapped into
your sinatra app at "/parts/blog_post", so it is equivalent of writing `get "/parts/blog_post"`.

## Application configuration

To make you Sinatra-app serve your kit, you have to register the PartsKit extension:

    class MyApp < Sinatra::Base
      set :root, File.dirname(__FILE__)+'/v1'  # Or wherever you keep your parts-folder and other Sinatra files
      register Sinatra::PartsKit
    end

Registering the extension loads all your parts and registers all routes and asset_paths. The following routes are 
provided by `PartsKit`:

    /parts                     # A json hash describing all parts provided in this kit
    /parts/client_templates    # All client side templates (mustache) wrapped in <script> tags
    /parts/<part name>         # The render `action` for parts that provide one
    /parts/assets/             # The root path of all assets in all your part-folders
    /parts/assets/parts.js     # All part scripts and anything else you required in /parts/parts.js
    /parts/assets/parts.css    # All parts stylesheets and anything else you required in /parts/parts.css
    /parts/assets/<asset_name> # Any asset in any of you parts folders.

Assets are served through Sprockets and processing is provided by it, so when requiring assets you should never
include pathnames in your url, only the "logical path" which is the name of the completely processed asset. So
if you e.g. have a coffescript in the folder /parts/my_part/my_special_script.js.coffee, you can get it compiled and ready
at the Sinatra application path `/parts/assets/my_special_script.js`. 

The sprockets environment used by PartsKit is available in your sinatra app as MyApp.kit_sprockets should you require
further configuration.
