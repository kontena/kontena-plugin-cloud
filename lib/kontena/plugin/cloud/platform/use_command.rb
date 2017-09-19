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
      org, platform = name.split('/')
      @current_organization = org
    else
      @current_organization = prompt_organization
    end
    if name
      require_platform(name)
      platform = find_platform_by_name(current_grid, current_organization)
    else
      platform = prompt_platform
    end

    platform_name = "#{current_organization}/#{platform.name}"
    unless platform_config_exists?(platform_name)
      spinner "Generating platform token" do
        login_to_platform(platform_name, platform.url)
      end
    else
      config.current_master = platform_name
      config.current_master.grid = platform.grid_id
      config.write
    end

    puts "Using platform: #{pastel.cyan(platform_name)}"
  end

end