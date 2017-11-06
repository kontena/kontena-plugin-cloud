require 'kontena_cli'
require 'kontena/command'
require_relative 'kontena/plugin/cloud'
require_relative 'kontena/plugin/cloud_command'

module Kontena
  module Cli
    module GridOptions
      def self.included(base)
        if base.respond_to?(:option)

          base.option '--platform', 'PLATFORM', 'Specify Kontena Cloud platform to use' do |platform|
            config.current_master = platform
            config.current_grid = platform.split('/')[1]
          end
          #base.option '--grid', 'GRID', 'Specify grid to use'
        end
      end
    end

    class Config

      # patch broken cli
      unless self.instance_methods.include?(:load_cloud_settings_from_env)

        def load_settings_from_env
          load_cloud_settings_from_env
          load_master_settings_from_env
        end

        def load_master_settings_from_env
          return nil unless ENV['KONTENA_URL']

          debug { 'Loading master configuration from ENV' }
          servers << Server.new(
            url: ENV['KONTENA_URL'],
            name: 'default',
            token: Token.new(access_token: ENV['KONTENA_TOKEN'], parent_type: :master, parent_name: 'default'),
            grid: ENV['KONTENA_GRID'],
            parent_type: :master,
            parent_name: 'default'
          )

          self.current_master  = 'default'
          self.current_account = 'kontena'
        end

        def load_cloud_settings_from_env
          return unless ENV['KONTENA_CLOUD_TOKEN']

          debug { 'Loading cloud configuration from ENV' }
          accounts << Account.new(kontena_account_data.merge(
            token: Token.new(access_token: ENV['KONTENA_CLOUD_TOKEN'], parent_type: :account, parent_name: 'default')
          ))
        end
      end
    end
  end

  module CloudCommand

    PLATFORM_NOT_SELECTED_ERROR = "Platform not selected, use 'kontena cloud platform use' to select a platform"

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

  module CloudClient
    def parse_response(response)
      data = super(response)
      if data.is_a?(Hash) && data['errors']
        data['error'] = {}
        errors = data.delete('errors')
        if errors.size == 1
          data['error'] = errors[0]['title']
        else
          errors.each do |e|
            data['error'][e['id']] = e['title']
          end
        end
      end
      data
    end
  end

  class Client
    prepend CloudClient
  end
end