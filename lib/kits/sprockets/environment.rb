require 'sprockets'

module Kits::Sprockets

  class JavascriptDirectiveProcessor < ::Sprockets::DirectiveProcessor
    def process_require_components_directive
      # context.environment returns a Sprockets::Index at this point.
      # This hackery introduced to get at the real Environment where
      # we keep our kit.
      environment = context.environment.instance_variable_get(:@environment)
      environment.kit.scripts.each do |path|
        context.require_asset(File.basename(path))
      end
    end
  end

  class CSSDirectiveProcessor < ::Sprockets::DirectiveProcessor
    def process_require_components_directive
      environment = context.environment.instance_variable_get(:@environment)
      environment.kit.stylesheets.each do |path|
        context.require_asset(path)
      end
    end
  end

  class Environment < ::Sprockets::Environment
    attr_reader :kit
    def initialize(root, kit)
      super(root)
      @kit = kit
      unregister_processor('text/css', ::Sprockets::DirectiveProcessor)
      unregister_processor('application/javascript', ::Sprockets::DirectiveProcessor)
      register_processor('text/css', Kits::Sprockets::CSSDirectiveProcessor)
      register_processor('application/javascript', Kits::Sprockets::JavascriptDirectiveProcessor)
      @kit.asset_paths.each { |path| append_path(path) }
    end
  end

end