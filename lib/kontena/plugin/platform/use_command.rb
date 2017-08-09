require_relative 'common'

class Kontena::Plugin::Platform::UseCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  def execute
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

  def prompt_platform
    platforms = fetch_platforms_for_org(current_organization)
    prompt.select("Choose platform") do |menu|
      platforms.each do |p|
        menu.choice p.name, p
      end
    end
  end
end