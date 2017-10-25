require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::Node::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper
  include Kontena::Plugin::Cloud::Node::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Organization::Common

  requires_current_account_token

  def execute
    org, platform = parse_platform_name(current_master.name)
    platform = require_platform("#{org}/#{platform}")
    nodes = compute_client.get("/organizations/#{org}/nodes")['data']
    nodes.delete_if { |n| n.dig('attributes', 'state') == 'terminated' }
    print_table(nodes) do |n|
      node = Kontena::Cli::Models::Node.new(n)
      n['name'] = "#{state_icon(node.state)} #{node.name}"
      n['type'] = node.type
      n['region'] = node.region
    end
  end

  def default_organization
    prompt_organization
  end

  def fields
    {
      'name' => 'name',
      'type' => 'type',
      'region' => 'region'
    }
  end

  def state_icon(state)
    case state
    when nil
      " ".freeze
    when 'running'.freeze
      pastel.green('⊛'.freeze)
    else
      pastel.dark('⊝'.freeze)
    end
  end
end