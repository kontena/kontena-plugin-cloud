require_relative '../../../cli/models/grid'
require_relative '../common'

class Kontena::Plugin::Platform::TrustedSubnet::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  parameter "NAME", "Platform name"
  parameter "SUBNET", "Subnet"

  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    require_platform(name)

    grid = client.get("grids/#{current_grid}")
    confirm_command(subnet) unless forced?
    trusted_subnets = grid['trusted_subnets'] || []
    unless trusted_subnets.delete(self.subnet)
      exit_with_error("Platform #{name.colorize(:cyan)} does not have trusted subnet #{subnet.colorize(:cyan)}")
    end
    data = {trusted_subnets: trusted_subnets}
    spinner "Removing trusted subnet #{subnet.colorize(:cyan)} from #{name.colorize(:cyan)} platform " do
      client.put("grids/#{current_grid}", data)
    end
  end
end