class Kontena::Cli::CloudCommand < Kontena::Command

  subcommand 'organization', 'Organization specific commands', load_subcommand('kontena/plugin/cloud/organization_command')
  subcommand 'datacenter', 'Datacenter specific commands', load_subcommand('kontena/plugin/cloud/datacenter_command')

  def execute
  end
end
