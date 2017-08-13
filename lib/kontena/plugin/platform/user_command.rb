require_relative 'common'

require_relative 'user/list_command'
require_relative 'user/add_command'
require_relative 'user/remove_command'
class Kontena::Plugin::Platform::UserCommand < Kontena::Command
  include Kontena::Plugin::Platform
  subcommand ['list', 'ls'], 'List platform users', User::ListCommand
  subcommand 'add', 'Add users to platform', User::AddCommand
  subcommand ['remove', 'rm'], 'Remove users from platform', User::RemoveCommand

  def execute
  end
end
