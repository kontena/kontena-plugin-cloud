require_relative 'common'

class Kontena::Plugin::Platform::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    require_platform(name)
    platform = find_platform_by_name(current_platform, current_organization)

    confirm_command(name) unless forced?

    spinner "Removing platform #{pastel.cyan(name)}" do
      cloud_client.delete("/organizations/#{current_organization}/platforms/#{platform.id}")
      remove_from_config(name)
    end
  end

  def remove_from_config(name)
    config.current_server = nil
    config.servers.delete_if {|s| s.name == name }
    config.write
  end
end