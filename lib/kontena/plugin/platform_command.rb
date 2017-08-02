class Kontena::Plugin::PlatformCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List platforms', load_subcommand('kontena/plugin/platform/list_command')
  subcommand ['use', 'switch'], 'Use/switch local scope to platform', load_subcommand('kontena/plugin/platform/use_command')
  subcommand 'show', 'Show platform details', load_subcommand('kontena/plugin/platform/show_command')
  subcommand 'create', 'Create new platform', load_subcommand('kontena/plugin/platform/create_command')
  subcommand ['remove', 'rm'], 'Remove platform', load_subcommand('kontena/plugin/platform/remove_command')
  subcommand 'audit-log', 'Show platform audit logs', load_subcommand('kontena/plugin/platform/audit_log_command')
  subcommand 'health', 'Show platform health', load_subcommand('kontena/plugin/platform/health_command')

  def execute
  end
end