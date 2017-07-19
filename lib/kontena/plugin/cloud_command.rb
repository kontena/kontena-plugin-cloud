require_relative 'cloud/organization_command'
require_relative 'cloud/datacenter_command'

class Kontena::Cli::CloudCommand < Kontena::Command

  include Kontena::Plugin::Cloud

  subcommand 'organization', 'Organization specific commands', OrganizationCommand
  subcommand 'datacenter', 'Datacenter specific commands', DatacenterCommand

  def execute
  end
end
