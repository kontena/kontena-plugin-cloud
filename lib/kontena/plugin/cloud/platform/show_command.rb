require 'kontena/cli/grids/common'
require_relative 'common'

class Kontena::Plugin::Cloud::Platform::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Cli::Grids::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  def execute
    require_platform(name)

    platform = find_platform_by_name(current_platform, current_organization)

    puts "#{name}:"
    puts "  name: #{platform.name}"
    puts "  organization: #{current_organization}"
    puts "  version: #{platform.version}"
    puts "  state: #{platform.state}"
    puts "  region: #{platform.region || '-'}"
    puts "  initial_size: #{platform.initial_size}"
    puts "  master: #{platform.url}"
    puts "  grid: #{platform.grid_id}"
  end
end