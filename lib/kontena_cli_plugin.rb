require 'kontena_cli'
require 'kontena/command'
require_relative 'kontena/plugin/cloud'
require_relative 'kontena/plugin/cloud_command'
require_relative 'kontena/plugin/platform_command'

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
          base.option '--grid', 'GRID', 'Specify grid to use'
        end
      end
    end
  end

  module CloudCommand

    PLATFORM_NOT_SELECTED_ERROR = "Platform not selected, use 'kontena platform use' to select a platform"

    def verify_current_master
      super
    rescue ArgumentError
      exit_with_error PLATFORM_NOT_SELECTED_ERROR
    end

    def verify_current_master_token
      super
    rescue ArgumentError
      exit_with_error PLATFORM_NOT_SELECTED_ERROR
    end

    def verify_current_grid
      super
    rescue ArgumentError
      exit_with_error PLATFORM_NOT_SELECTED_ERROR
    end
  end

  class Command < Clamp::Command
    prepend CloudCommand
  end
end