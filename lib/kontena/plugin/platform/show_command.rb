require 'kontena/cli/grids/common'
require_relative 'common'
require_relative '../../cli/models/grid'

class Kontena::Plugin::Platform::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common
  include Kontena::Cli::Grids::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  def execute
    require_platform(name)

    platform = find_platform_by_name(current_platform, current_organization)

    puts "#{name}:"
    puts "  name: #{platform.name}"
    puts "  organization: #{current_organization}"
    puts "  state: #{platform.state}"
    puts "  region: #{platform.region || '-'}"
    puts "  initial_size: #{platform.initial_size}"
    puts "  master: #{platform.url}"

    grid = nil
    begin
      data = client.get("grids/#{platform.grid_id}")
      grid = Kontena::Cli::Models::Grid.new(data)
    rescue Kontena::Errors::StandardError
      exit_with_error "Cannot fetch grid information"
    end

    if grid.default_affinity?
      puts "  default_affinity: "
      grid.default_affinity.to_a.each do |a|
        puts "    - #{a}"
      end
    else
      puts "  default_affinity: -"
    end
    puts "  subnet: #{grid.subnet}"
    puts "  supernet: #{grid.supernet}"
    if grid.stats.statsd?
      statsd = grid.stats.statsd
      puts "  exports:"
      puts "    statsd: #{statsd.server}:#{statsd.port}"
    end
    if grid.logs.forwarder?
      puts "logs:"
      puts "  forwarder: #{grid.logs.forwarder}"
      grid.logs.opts.each do |k,v|
        puts "  #{k}: #{v}"
      end
    end
  end
end