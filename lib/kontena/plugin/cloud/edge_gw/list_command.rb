require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::EdgeGw::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper
  include Kontena::Plugin::Cloud::EdgeGw::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Organization::Common

  requires_current_account_token

  option ['--organization', '--org'], 'ORG', 'Organization', environment_variable: "KONTENA_ORGANIZATION"
  option ['--quiet', '-q'], :flag, 'Output the identifying column only'

  def execute
    gws = compute_client.get("/organizations/#{self.organization}/edge-gateways")['data']
    if quiet?
      puts gws.map { |n| n.dig('attributes', 'name')}
      return
    end
    platforms = fetch_platforms(gws)
    print_table(gws) do |l|
      gw = Kontena::Cli::Models::EdgeGateway.new(l)
      l['name'] = "#{state_icon(gw.state)} #{gw.name}"
      l['region'] = gw.region
      if platform = platforms[gw.platform_id]
        l['platform'] = platform.to_path
      else
        l['platform'] = pastel.red('<orphan>')
      end
      l['nodes'] = gw.node_ids.size
    end
  end

  def fetch_platforms(gws)
    platform_ids = gws.map { |g| Kontena::Cli::Models::EdgeGateway.new(g).platform_id }.compact.uniq
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
      'platform' => 'platform',
      'nodes' => 'nodes',
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