require_relative 'common'

class Kontena::Plugin::Platform::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    require_platform(name)
    platform = fetch_platforms_for_org(current_organization).find { |p| p.dig('attributes', 'name') == current_grid }
    exit_with_error "Platform not found: #{name}" unless platform

    confirm_command(name) unless forced?

    spinner "Removing platform #{pastel.cyan(name)}" do
      cloud_client.delete("/organizations/#{current_organization}/platforms/#{platform['id']}")
      remove_from_config(name)
    end
  end

  def remove_from_config(name)
    config.current_server = nil
    config.servers.delete_if {|s| s.name == name }
    config.write
  end
end