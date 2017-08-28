class Kontena::Plugin::Cloud::OrganizationCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List organizations', load_subcommand('kontena/plugin/cloud/organization/list_command')
  subcommand 'show', 'Show organization details', load_subcommand('kontena/plugin/cloud/organization/show_command')
  subcommand ['remove', 'rm'], 'Remove organization', load_subcommand('kontena/plugin/cloud/organization/remove_command')
  subcommand 'user', 'User management commands', load_subcommand('kontena/plugin/cloud/organization/user_command')

  def execute
  end
end