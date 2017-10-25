require 'kontena/cli/grids/common'
require_relative 'common'
require_relative '../organization/common'

class Kontena::Plugin::Cloud::Platform::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Organization::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Cli::Grids::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  def execute
    unless name
      @current_organization = prompt_organization
      platform = prompt_platform
      platform_name = platform.to_path
    else
      platform_name = name
    end
    require_platform(platform_name)
    org, name = parse_platform_name(platform_name)

    platform = find_platform_by_name(name, org)

    puts "#{platform.to_path}:"
    puts "  name: #{platform.name}"
    puts "  organization: #{platform.organization}"
    puts "  version: #{platform.version}"
    puts "  state: #{platform.state}"
    puts "  online: #{platform.online}"
    puts "  region: #{platform.region || '-'}"
    puts "  initial_size: #{platform.initial_size}"
    puts "  master: #{platform.url}"
    puts "  grid: #{platform.grid_id}"
  end
end