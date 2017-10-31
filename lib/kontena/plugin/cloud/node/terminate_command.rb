require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::Node::TerminateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Node::Common
  include Kontena::Plugin::Cloud::Node::PlatformOption

  requires_current_account_token

  parameter "[NAME]", "Node name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    org, platform = parse_platform_name(current_master.name)
    unless self.name
      name = prompt_name(platform, org)
    else
      exit_with_error "Invalid name" if org.nil? || platform.nil?
      name = self.name
    end

    confirm_command(name) unless forced?

    nodes = compute_client.get("/organizations/#{org}/nodes")['data'].map { |n|
      Kontena::Cli::Models::Node.new(n)
    }
    node = nodes.find { |n| n.name == name }
    exit_with_error "Node not found" unless node

    spinner "Terminating node #{pastel.cyan(node.name)} from platform #{pastel.cyan("#{org}/#{platform}")}" do
      compute_client.delete("/organizations/#{org}/nodes/#{node.id}")
    end
    platform = get_platform(org, node.platform_id)
    if platform
      client.delete("nodes/#{current_grid}/#{name}")
    end
  end

  def prompt_name(platform, org)
    platform = find_platform_by_name(platform, org)
    exit_with_error "Platform not selected" unless platform

    nodes = compute_client.get("/organizations/#{org}/nodes")['data'].map { |n|
      Kontena::Cli::Models::Node.new(n)
    }
    nodes.delete_if { |n| n.platform_id != platform.id || n.state == 'terminated' }
    exit_with_error "No nodes" if nodes.size == 0
    grid_nodes = client.get("grids/#{current_grid}/nodes")['nodes']
    prompt.select("Choose node") do |menu|
      nodes.each do |node|
        grid_node = grid_nodes.find { |n| n['name'] == node.name }
        if grid_node
          menu.choice "#{node.name} #{grid_node['initial_member'] ? '(initial)' : ''}", node.name
        else
          menu.choice "#{node.name} (orphan)", node.name
        end
      end
    end
  end
end