require_relative 'common'

class Kontena::Plugin::Platform::UseCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  def execute
    if name
      require_platform(name)
    else
      platform = prompt_platform
    end

    master_name = platform['name']
    master = config.find_server(master_name)
    if master.nil?
      Kontena.run([
        'master', 'login',
        '--name', master_name,
        platform.dig('attributes', 'url')
      ])
    else
      config.current_master = master['name']
      config.current_master.grid = platform.dig('attributes', 'grid-id')
      config.write
      puts "Using platform: #{pastel.cyan(platform['name'])}"
    end
  end

  def prompt_platform
    platforms = fetch_platforms
    prompt.select("Choose platform") do |menu|
      platforms.each do |p|
        menu.choice p['name'], p
      end
    end
  end
end