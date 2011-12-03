require 'set'
require 'sinatra'

class Kits::Kit < Sinatra::Base
  @@fragments = []
  
  def self.fragments
    @@fragments
  end

  def self.fragment(name, &block)
    puts "builder"
    fragment = Kits::Fragment.define(self, name, &block)
    puts "adding"
    @@fragments << fragment
    puts "routing"
    get("/fragments/#{name}", {}, &fragment.action)
    puts "done"
  end
end