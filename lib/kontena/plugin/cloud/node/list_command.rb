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

  option ['--organization', '--org'], 'ORG', 'Organization', environment_variable: "KONTENA_ORGANIZATION"
  option ['--quiet', '-q'], :flag, 'Output the identifying column only'

  def execute
    nodes = compute_client.get("/organizations/#{self.organization}/nodes")['data']
    nodes.delete_if { |n| n.dig('attributes', 'state') == 'terminated' }
    if quiet?
      puts nodes.map { |n| n.dig('attributes', 'name')}
      return
    end
    platforms = fetch_platforms(nodes)
    print_table(nodes) do |n|
      node = Kontena::Cli::Models::Node.new(n)
      n['name'] = "#{state_icon(node.state)} #{node.name}"
      n['type'] = node.type
      n['region'] = node.region
      if platform = platforms[node.platform_id]
        n['platform'] = platform.to_path
      else
        n['platform'] = pastel.red('<orphan>')
      end
    end
  end

  def fetch_platforms(nodes)
    platform_ids = nodes.map { |n| Kontena::Cli::Models::Node.new(n).platform_id }.compact.uniq
    platforms = {}
    platform_ids.each { |id|
      platform_data = cloud_client.get("/organizations/#{self.organization}/platforms/#{id}")['data'] rescue nil
      if platform_data
        platforms[id] = Kontena::Cli::Models::Platform.new(platform_data)
      end
    }
    platforms
  end

  def default_organization
    unless current_master
      exit_with_error "Organization is required"
    end
    org, _ = parse_platform_name(current_master.name)
    org
  end

  def fields
    {
      'name' => 'name',
      'type' => 'type',
      'platform' => 'platform',
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