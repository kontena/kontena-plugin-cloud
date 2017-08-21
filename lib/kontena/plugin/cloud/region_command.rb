class Kontena::Plugin::Cloud::RegionCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List regions', load_subcommand('kontena/plugin/cloud/region/list_command')

  def execute
  end
end