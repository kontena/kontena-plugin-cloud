class Kontena::Plugin::Cloud::TokenCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List personal access tokens', load_subcommand('kontena/plugin/cloud/token/list_command')
  subcommand 'create', 'Create personal access token', load_subcommand('kontena/plugin/cloud/token/create_command')
  subcommand ['remove', 'rm'], 'Remove personal access token', load_subcommand('kontena/plugin/cloud/token/remove_command')
  def execute
  end
end