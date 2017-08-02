require 'kontena/cli/grids/audit_log_command'
require_relative 'common'

class Kontena::Plugin::Platform::AuditLogCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common
  include Kontena::Cli::TableGenerator::Helper

  parameter "NAME", "Platform name"

  option ["-l", "--lines"], "LINES", "Number of lines"

  def execute
    require_platform(name)

    audit_logs = client.get("grids/#{current_grid}/audit_log", {limit: lines})['logs']
    print_table(audit_logs) do |a|
      a['user'] = a['user_identity']['email']
      a['resource'] = a['resource_name'] ? "#{a['resource_type']}:#{a['resource_name']}" : a['resource_type']
    end
  end

  def fields
    {
      'time' => 'time',
      'resource' => 'resource',
      'event' => 'event_name',
      'user' => 'user',
      'source ip' => 'source_ip',
      'user agent' => 'user_agent'
    }
  end
end