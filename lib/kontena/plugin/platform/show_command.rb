require_relative 'common'

class Kontena::Plugin::Platform::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  def execute
    org_name, platform_name = name.split('/')
    exit_with_error("Invalid name") if platform_name.nil?
    platform = fetch_platforms_for_org(org_name).find { |p| p.dig('attributes', 'name') == platform_name }
    exit_with_error "Platform not found: #{name}" unless platform

    puts "#{name}:"
    puts "  id: #{platform['id']}"
    puts "  name: #{platform.dig('attributes', 'name')}"
    puts "  organization: #{org_name}"
    puts "  state: #{platform.dig('attributes', 'state')}"
    puts "  datacenter: #{platform.dig('relationships', 'datacenter', 'data', 'id')}"
    puts "  initial_size: #{platform.dig('attributes', 'initial-size')}"
    puts "  master: #{platform.dig('attributes', 'url')}"
  end
end