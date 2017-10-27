class Kontena::Plugin::Cloud::NodeCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List cloud nodes', load_subcommand('kontena/plugin/cloud/node/list_command')
  subcommand ['shell'], 'Jump into node shell', load_subcommand('kontena/plugin/cloud/node/shell_command')
  subcommand ['create'], 'Create cloud node', load_subcommand('kontena/plugin/cloud/node/create_command')
  subcommand ['terminate'], 'Terminate cloud node', load_subcommand('kontena/plugin/cloud/node/terminate_command')

  def execute
  end
end