class Kontena::Cli::CloudCommand < Kontena::Command

  subcommand 'platform', 'Kontena platform specific commands', load_subcommand('kontena/plugin/cloud/platform_command')
  subcommand 'node', 'Kontena node specific commands', load_subcommand('kontena/plugin/cloud/node_command')
  subcommand ['organization', 'org'], 'Organization specific commands', load_subcommand('kontena/plugin/cloud/organization_command')
  subcommand 'region', 'Region specific commands', load_subcommand('kontena/plugin/cloud/region_command')

  def execute
  end
end
