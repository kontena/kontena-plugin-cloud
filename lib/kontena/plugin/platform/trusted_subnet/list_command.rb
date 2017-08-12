require_relative '../../../cli/models/grid'
require_relative '../common'
require 'ipaddr'

class Kontena::Plugin::Platform::TrustedSubnet::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common
  include Kontena::Cli::TableGenerator::Helper

  parameter "NAME", "Platform name"

  def execute
    require_platform(name)
    grid = Kontena::Cli::Models::Grid.new(client.get("grids/#{current_grid}"))
    if grid.trusted_subnets.size > 0
      nodes = client.get("grids/#{current_grid}/nodes")['nodes']
    else
      nodes = []
    end
    items = grid.trusted_subnets.map { |s|
      item = {
        'subnet' => s
      }
      subnet = IPAddr.new(s)
      item['nodes'] = trusted_nodes(subnet, nodes).map { |n| n['name'] }.join(',')

      item
    }

    print_table(items)
  end

  # @param [IPAddr] subnet
  # @param [Array<Hash>] nodes
  def trusted_nodes(subnet, nodes)
    nodes.select { |n|
      begin
        n['private_ip'] && subnet.include?( IPAddr.new(n['private_ip']) )
      rescue => exc
        STDERR.puts "Failed to parse #{n['private_ip']} (#{n['name']}): #{exc.message}"
      end
    }
  end

  def fields
    {
      subnet: 'subnet',
      nodes: 'nodes'
    }
  end
end