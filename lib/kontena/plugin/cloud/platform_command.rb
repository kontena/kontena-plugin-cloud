class Kontena::Plugin::Cloud::PlatformCommand < Kontena::Command
  subcommand ['list', 'ls'], 'List platforms', load_subcommand('kontena/plugin/cloud/platform/list_command')
  subcommand ['use', 'switch'], 'Use/switch local scope to platform', load_subcommand('kontena/plugin/cloud/platform/use_command')
  subcommand 'show', 'Show platform details', load_subcommand('kontena/plugin/cloud/platform/show_command')
  subcommand 'create', 'Create new platform', load_subcommand('kontena/plugin/cloud/platform/create_command')
  subcommand ['remove', 'rm'], 'Remove platform', load_subcommand('kontena/plugin/cloud/platform/remove_command')
  subcommand ['join', 'byo'], 'Join grid as Kontena Platform', load_subcommand('kontena/plugin/platform/import_grid_command')
  subcommand 'user', 'User management commands', load_subcommand('kontena/plugin/cloud/platform/user_command')

  def execute
  end
end