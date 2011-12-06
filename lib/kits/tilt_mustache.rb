require 'tilt'

module Tilt
  class MustacheTemplate < Template
    self.default_mime_type = "text/html"
    def initialize_engine
      return if defined? ::Mustache
      require_template_library 'mustache'
    end

    def prepare; end

    def evaluate(scope, locals, &block)      
      Mustache.render(data, locals.merge(scope.is_a?(Hash) ? scope : {}).merge({:yield => block.nil? ? '' : block.call}))
    end
  end
  register MustacheTemplate, 'mustache'
end
