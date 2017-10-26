require 'kontena/machine/random_name'
require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::Node::CreateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Machine::RandomName
  include Kontena::Plugin::Cloud::Node::Common
  include Kontena::Plugin::Cloud::Organization::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  option "--count", "COUNT", "How many nodes to create" do |count|
    Integer(count)
  end
  option "--type", "TYPE", "Node type", required: true
  option "--region", "REGION", "Region (us-east-1, eu-west-1, defaults to current platform region)"

  def execute
    org, platform = parse_platform_name(current_master.name)
    platform = require_platform("#{org}/#{platform}")
    grid = client.get("grids/#{current_grid}")
    self.count.times do
      create_node(platform, grid['token'])
    end
  end

  def create_node(platform, token)
    name = "#{generate_name}-#{rand(1..999)}"
    node_token = SecureRandom.hex(32)
    target_region = self.region || platform.region
    spinner "Provisioning a node #{pastel.cyan(name)} to platform #{pastel.cyan(platform.to_path)}, region #{pastel.cyan(target_region)}" do
      client.post("grids/#{current_grid}/nodes", {
        name: name,
        token: node_token
      })

      data = {
        type: 'nodes',
        attributes: {
          name: name,
          type: self.type,
          region: target_region,
          tokens: {
            grid: token,
            node: node_token
          }
        },
        relationships: {
          platform: {
            data: {
              type: 'platforms',
              id: platform.id
            }
          }
        }
      }
      compute_client.post("/organizations/#{current_organization}/nodes", { data: data })
    end
  end

  def default_count
    prompt.ask("How many nodes?", default: 1).to_i
  end

  def default_type
    node_types = compute_client.get("/node_types")['data']
    prompt.select("Choose node type:") do |menu|
      menu.default 3
      node_types.each do |t|
        menu.choice "#{t['id']} (#{t.dig('attributes', 'cpus')}xCPU, #{t.dig('attributes', 'memory')}GB, #{t.dig('attributes', 'disk')}GB SSD)"
      end
    end
  end
end