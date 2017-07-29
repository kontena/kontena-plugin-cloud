require_relative 'common'

class Kontena::Plugin::Platform::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    org_name, platform_name = name.split('/')
    exit_with_error("Invalid name") if platform_name.nil?
    platform = fetch_platforms_for_org(org_name).find { |p| p.dig('attributes', 'name') == platform_name }
    exit_with_error "Platform not found: #{name}" unless platform

    confirm_command(name) unless forced?

    spinner "Removing platform #{name} from datacenter #{platform.dig('attributes', 'datacenter-id')}" do
      cloud_client.delete("/organizations/#{org_name}/platforms/#{platform['id']}")
      remove_from_config(name)
    end
  end

  def remove_from_config(name)
    config.servers.delete_at(config.find_server_index(name))
    if config.current_server && config.current_server.name == name
      config.current_server = nil
    end
    config.write
  end
end