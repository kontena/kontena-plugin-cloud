require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::EdgeGw::TerminateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::EdgeGw::Common

  requires_current_account_token

  parameter "[NAME]", "Edge gateway name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    org, platform = parse_platform_name(current_master.name)
    unless self.name
      name = prompt_name(platform, org)
    else
      exit_with_error "Invalid name" if org.nil? || platform.nil?
      name = self.name
    end

    confirm_command(name) unless forced?

    gws = compute_client.get("/organizations/#{org}/edge-gateways")['data'].map { |g|
      Kontena::Cli::Models::EdgeGateway.new(g)
    }
    gw = gws.find { |g| g.name == name }
    exit_with_error "Edge gateway not found" unless gw

    spinner "Terminating edge gateway #{pastel.cyan(gw.name)} from platform #{pastel.cyan("#{org}/#{platform}")}" do
      compute_client.delete("/organizations/#{org}/edge-gateways/#{gw.id}")
    end
  end

  def prompt_name(platform, org)
    platform = find_platform_by_name(platform, org)
    exit_with_error "Platform not selected" unless platform

    load_balancers = compute_client.get("/organizations/#{org}/load-balancers")['data'].map { |l|
      Kontena::Cli::Models::LoadBalancer.new(l)
    }

    load_balancers.delete_if { |l| l.platform_id != platform.id || l.state == 'terminated' }
    exit_with_error "No load balancers" if load_balancers.size == 0

    prompt.select("Choose load balancer") do |menu|
      load_balancers.each do |lb|
        menu.choice "#{org}/#{lb.name}", lb.name
      end
    end
  end
end