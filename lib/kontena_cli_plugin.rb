require 'kontena_cli'
require_relative 'kontena/plugin/cloud'
require_relative 'kontena/plugin/cloud_command'
require_relative 'kontena/plugin/platform_command'
require_relative 'kontena/plugin/grid_command'

Kontena::MainCommand.register("platform", "Platform specific commands", Kontena::Plugin::PlatformCommand)

module Kontena
  module Cli
    module GridOptions

      def self.included(base)
        if base.respond_to?(:option)
          base.option '--platform', 'PLATFORM', 'Specify platform to use' do |platform|
            config.current_master = platform
            config.current_grid = platform.split('/')[1]
          end
        end
      end
    end
  end
end