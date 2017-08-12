require_relative '../../../cli/models/grid'
require_relative '../common'

class Kontena::Plugin::Platform::TrustedSubnet::AddCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  parameter "NAME", "Platform name"
  parameter "SUBNET", "Subnet"

  def execute
    require_platform(name)

    grid = client.get("grids/#{current_grid}")
    data = {trusted_subnets: grid['trusted_subnets'] + [self.subnet]}
    spinner "Adding #{subnet.colorize(:cyan)} as a trusted subnet in #{current_grid.colorize(:cyan)} platform " do
      client.put("grids/#{current_grid}", data)
    end
  end
end