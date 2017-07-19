require_relative 'datacenter/list_command'

class Kontena::Plugin::Cloud::DatacenterCommand < Kontena::Command
  include Kontena::Plugin::Cloud

  subcommand ['list', 'ls'], 'List datacenters', Datacenter::ListCommand

  def execute
  end
end