require_relative 'common'

class Kontena::Plugin::Platform::TrustedSubnetCommand < Kontena::Command

  subcommand ["list", "ls"], "List trusted subnets", load_subcommand('kontena/plugin/platform/trusted_subnet/list_command')
  subcommand ["add"], "Add trusted subnet", load_subcommand('kontena/plugin/platform/trusted_subnet/add_command')
  subcommand ["remove", "rm"], "Remove trusted subnet", load_subcommand('kontena/plugin/platform/trusted_subnet/remove_command')

  def execute
  end
end
