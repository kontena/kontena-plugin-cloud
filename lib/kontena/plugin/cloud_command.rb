class Kontena::Cli::CloudCommand < Kontena::Command

  subcommand 'platform', 'Kontena platform specific commands', load_subcommand('kontena/plugin/cloud/platform_command')
  subcommand 'node', 'Kontena node specific commands', load_subcommand('kontena/plugin/cloud/node_command')
  subcommand ['edge-gateway', 'eg'], 'Kontena edge gateway specific commands', load_subcommand('kontena/plugin/cloud/edge_gw_command')
  subcommand ['organization', 'org'], 'Organization specific commands', load_subcommand('kontena/plugin/cloud/organization_command')
  subcommand ['image-repository', 'ir'], 'Image repository specific commands', load_subcommand('kontena/plugin/cloud/image_command')
  subcommand 'region', 'Region specific commands', load_subcommand('kontena/plugin/cloud/region_command')
  subcommand 'token', 'Personal access token specific commands', load_subcommand('kontena/plugin/cloud/token_command')

  def execute
  end
end
