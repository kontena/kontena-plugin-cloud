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
      platform = require_platform(name)
    else
      @current_organization = prompt_organization
      platform = prompt_platform
      require_platform(platform.to_path)
    end

    config.current_master = platform.to_path
    config.current_master.grid = platform.grid_id
    config.write
    puts "Using platform: #{pastel.cyan(platform.to_path)}"
  end

end