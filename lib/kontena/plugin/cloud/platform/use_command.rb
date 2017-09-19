require_relative 'common'
require_relative '../organization/common'

class Kontena::Plugin::Cloud::Platform::UseCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Organization::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  def execute
    if name && name.include?('/')
      org = name.split('/').first
      @current_organization = org
      platform = require_platform(name)
    end
    unless platform
      @current_organization = prompt_organization
      platform = prompt_platform
      require_platform(platform.to_path)
    end

    unless platform_config_exists?(platform.to_path)
      spinner "Generating platform token" do
        login_to_platform(platform.name, platform.url)
      end
    else
      config.current_master = platform.to_path
      config.current_master.grid = platform.grid_id
      config.write
    end

    puts "Using platform: #{pastel.cyan(platform.to_path)}"
  end

end