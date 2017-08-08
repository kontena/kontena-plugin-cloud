require_relative 'region/list_command'

class Kontena::Plugin::Cloud::RegionCommand < Kontena::Command
  include Kontena::Plugin::Cloud

  subcommand ['list', 'ls'], 'List regions', Region::ListCommand

  def execute
  end
end