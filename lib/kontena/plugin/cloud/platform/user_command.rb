
class Kontena::Plugin::Cloud::Platform::UserCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List platform users', load_subcommand('kontena/plugin/cloud/platform/user/list_command')
  subcommand 'add', 'Add users to platform', load_subcommand('kontena/plugin/cloud/platform/user/add_command')
  subcommand ['remove', 'rm'], 'Remove users from platform', load_subcommand('kontena/plugin/cloud/platform/user/remove_command')

  def execute
  end
end
