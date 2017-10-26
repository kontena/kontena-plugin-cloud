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

  NODE_TYPES = {
    'k1' => '1CPU, 1GB, 30GB SSD',
    'k2' => '1CPU, 2GB, 60GB SSD',
    'k4' => '2CPU, 4GB, 120GB SSD',
    'k8' => '2CPU, 8GB, 240GB SSD',
    'k16' => '4CPU, 16GB, 480GB SSD'
  }

  requires_current_account_token

  option "--count", "COUNT", "How many nodes to create" do |count|
    Integer(count)
  end
  option "--type", "TYPE", "Node type (k1, k2, k4, k8, k16)", required: true
  option "--region", "REGION", "Region (us-east-1, eu-west-1, defaults to platform region)"

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
    spinner "Provisioning node #{pastel.cyan(name)} to platform #{pastel.cyan(platform.to_path)}, region #{pastel.cyan(self.region)}" do
      client.post("grids/#{current_grid}/nodes", {
        name: name,
        token: node_token
      })

      data = {
        type: 'nodes',
        attributes: {
          name: name,
          type: self.type,
          region: platform.region,
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
    prompt.ask("How many nodes?", default: 1)
  end

  def default_type
    prompt.select("Choose node type:") do |menu|
      menu.default 3
      NODE_TYPES.each do |id, name|
        menu.choice "#{id} (#{name})", id
      end
    end
  end
end