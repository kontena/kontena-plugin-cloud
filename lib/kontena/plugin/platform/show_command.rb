require_relative 'common'

class Kontena::Plugin::Platform::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  def execute
    require_platform(name)

    platform = find_platform_by_name(current_platform, current_organization)

    puts "#{name}:"
    puts "  id: #{platform.id}"
    puts "  name: #{platform.name}"
    puts "  organization: #{current_organization}"
    puts "  state: #{platform.state}"
    puts "  region: #{platform.region || '-'}"
    puts "  initial_size: #{platform.initial_size}"
    puts "  master: #{platform.url}"
  end
end