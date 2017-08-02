
require 'kontena/cli/grid_command'
class Kontena::Cli::GridCommand < Kontena::Command

  subcommand 'platform-migrate', 'Migrate grid to Kontena Cloud platform', load_subcommand('kontena/plugin/grid/platform_migrate_command')

  def execute
  end
end
