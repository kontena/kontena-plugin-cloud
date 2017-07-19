require_relative 'organization/list_command'
require_relative 'organization/show_command'
require_relative 'organization/user_command'

class Kontena::Plugin::Cloud::OrganizationCommand < Kontena::Command
  include Kontena::Plugin::Cloud

  subcommand ['list', 'ls'], 'List organizations', Organization::ListCommand
  subcommand 'show', 'Show organization details', Organization::ShowCommand

  subcommand 'user', 'User management commands', Organization::UserCommand
  def execute
  end
end