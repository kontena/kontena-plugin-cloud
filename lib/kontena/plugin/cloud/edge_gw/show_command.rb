require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::EdgeGw::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Util
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::EdgeGw::Common

  requires_current_account_token

  parameter "NAME", "Edge gateway name"

  def execute
    org, platform = parse_platform_name(current_master.name)
    unless self.name
      name = prompt_name(platform, org)
    else
      exit_with_error "Invalid name" if org.nil? || platform.nil?
      name = self.name
    end

    gws = compute_client.get("/organizations/#{org}/edge-gateways")['data'].map { |g|
      Kontena::Cli::Models::EdgeGateway.new(g)
    }
    gw = gws.find { |g| g.name == name }
    exit_with_error "Edge gateway not found" unless gw

    puts "#{gw.organization_id}/#{gw.name}:"
    puts "  id: #{gw.id}"
    puts "  created_at: #{time_ago(gw.created_at.to_i)}"
    puts "  region: #{gw.region}"
    puts "  state: #{gw.state}"
    puts "  nodes:"
    gw.node_ids.map { |nid|
      Kontena::Cli::Models::Node.new(compute_client.get("/organizations/#{org}/nodes/#{nid}")['data'])
    }.each do |node|
      puts "    - #{node.name}"
    end
  end
end