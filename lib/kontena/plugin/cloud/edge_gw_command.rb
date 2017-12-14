class Kontena::Plugin::Cloud::EdgeGwCommand < Kontena::Command

  subcommand ['create'], 'Create cloud edge gateway', load_subcommand('kontena/plugin/cloud/edge_gw/create_command')
  subcommand ['list', 'ls'], 'List cloud edge gateways', load_subcommand('kontena/plugin/cloud/edge_gw/list_command')
  subcommand ['show'], 'Show cloud edge gateway details', load_subcommand('kontena/plugin/cloud/edge_gw/show_command')
  subcommand ['terminate', 'rm'], 'Terminate cloud edge gateway', load_subcommand('kontena/plugin/cloud/edge_gw/terminate_command')

  def execute
  end
end