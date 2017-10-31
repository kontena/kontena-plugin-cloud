require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::Node::ShellCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Node::PlatformOption
  include Kontena::Plugin::Cloud::Node::Common

  requires_current_account_token

  parameter "NAME", "Node name"
  parameter "[CMD] ...", "Command"

  def execute
    service_name = "#{name}-shell-#{rand(1..10_000)}"

    service = nil
    spinner "Creating shell session to node #{pastel.cyan(name)}" do
      service = create_service(service_name, name)
    end

    exec_opts = ['-i']
    exec_opts << 't' if STDIN.tty?
    if cmd_list.empty?
      exec_command = ''
    else
      exec_command = "-c \"#{cmd_list.join(' ')}\""
    end

    Kontena.run!([
      'service', 'exec', exec_opts.join(''), '--shell', service_name,
      "nsenter --target 1 --mount --uts --net --pid -- su #{exec_command} - core"
    ])
  ensure
    remove_service(service) if service
  end

  def create_service(service_name, node_name)
    data = {
      name: service_name,
      image: 'kontena/nsenter:latest',
      stateful: false,
      cmd: ['sleep', '60000'],
      pid: 'host',
      privileged: true,
      affinity: [
        "node==#{node_name}"
      ],
      env: [
        "TERM=xterm"
      ]
    }
    service = client.post("grids/#{current_grid}/services", data)
    deployment = client.post("services/#{service['id']}/deploy", {})
    until deployment['finished_at'] do
      sleep 1
      deployment = client.get("services/#{service['id']}/deploys/#{deployment['id']}", {})
    end

    service
  end

  def remove_service(service)
    client.delete("services/#{service['id']}", {})
  end
end