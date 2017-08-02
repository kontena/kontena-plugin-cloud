require_relative 'common'

class Kontena::Plugin::Platform::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  def execute
    require_platform(name)

    platform = find_platform_by_name(current_grid, current_organization)

    puts "#{name}:"
    puts "  id: #{platform['id']}"
    puts "  name: #{platform.dig('attributes', 'name')}"
    puts "  organization: #{current_organization}"
    puts "  state: #{platform.dig('attributes', 'state')}"
    puts "  region: #{platform.dig('relationships', 'datacenter', 'data', 'id')}"
    puts "  initial_size: #{platform.dig('attributes', 'initial-size')}"
    puts "  master: #{platform.dig('attributes', 'url')}"
  end
end