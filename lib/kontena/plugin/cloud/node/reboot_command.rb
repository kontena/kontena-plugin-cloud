require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::Node::RebootCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Node::Common

  requires_current_account_token

  option ['--organization', '--org'], 'ORG', 'Organization', environment_variable: "KONTENA_ORGANIZATION"
  parameter "NAME", "Node name"

  def execute
    spinner "Sending reboot request to #{pastel.cyan(name)}" do
      node = find_node(name)
      compute_client.post("/organizations/#{self.organization}/nodes/#{node.dig('id')}/reboot", {})
    end
  end

  def find_node(name)
    nodes = compute_client.get("/organizations/#{self.organization}/nodes")['data']
    nodes.find { |n| n.dig('attributes', 'name') == name }
  end

  def default_organization
    unless current_master
      exit_with_error "Organization is required"
    end
    org, _ = parse_platform_name(current_master.name)
    org
  end
end