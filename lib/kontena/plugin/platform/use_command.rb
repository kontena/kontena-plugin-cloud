require_relative 'common'

class Kontena::Plugin::Platform::UseCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"
  option '--[no-]remote', :flag, 'Login using a browser on another device', default: Kontena.browserless?

  def execute
    if name
      require_platform(name)
      platform = find_platform_by_name(name, current_organization)
    else
      platform = prompt_platform
    end

    unless platform_config_exists?(platform.dig('attributes', 'name'))
      login_to_platform(platform.dig('attributes', 'name'), platform.dig('attributes', 'url'), remote: remote?)
      puts ""
    else
      config.current_master = platform.dig('attributes', 'name')
      config.current_master.grid = platform.dig('attributes', 'grid-id')
      config.write
    end

    puts "Using platform: #{pastel.cyan(platform.dig('attributes', 'name'))}"
  end

  def prompt_platform
    platforms = fetch_platforms_for_org(current_organization)
    prompt.select("Choose platform") do |menu|
      platforms.each do |p|
        menu.choice p['name'], p
      end
    end
  end
end