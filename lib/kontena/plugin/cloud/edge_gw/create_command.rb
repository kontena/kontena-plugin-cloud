require 'resolv'
require 'kontena/machine/random_name'
require_relative 'common'
require_relative '../organization/common'
require_relative '../platform/common'

class Kontena::Plugin::Cloud::EdgeGw::CreateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Machine::RandomName
  include Kontena::Plugin::Cloud::EdgeGw::Common
  include Kontena::Plugin::Cloud::Organization::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  parameter "[NAME]", "Cloud edge gateway name"
  option "--region", "REGION", "Region (us-east-1, eu-west-1, defaults to current platform region)"
  option "--[no-]wait-dns", :flag, "Wait for edge gateway DNS to resolve", default: true

  def execute
    org, platform = parse_platform_name(current_platform)
    platform = require_platform("#{org}/#{platform}")

    target_region = self.region || platform.region
    name = self.name || "#{generate_name}-#{rand(1..99)}"
    data = {
      type: 'edge-gateways',
      attributes: {
        name: name,
        region: target_region
      },
      relationships: {
        platform: {
          data: {
            type: 'platforms',
            id: platform.id
          }
        }
      }
    }
    response = spinner "Provisioning an edge gateway #{pastel.cyan(name)} to platform #{pastel.cyan(platform.to_path)}, region #{pastel.cyan(target_region)}" do
      compute_client.post("/organizations/#{current_organization}/edge-gateways", { data: data })
    end
    gw = Kontena::Cli::Models::EdgeGateway.new(response['data'])
    if wait_dns?
      resolver = Resolv::DNS.new(nameserver: ['8.8.8.8', '8.8.4.4'])
      spinner "Waiting for edge gateway #{pastel.cyan(name)} dns #{pastel.cyan(gw.dns)} to resolve" do
        sleep 60
        while resolver.getaddresses(gw.dns).size == 0
          sleep 5
        end
      end
    else
      puts ""
      puts " Kontena Cloud Edge Gateway is now available at #{pastel.cyan(gw.dns)} (DNS propagation might take few minutes)"
    end
  end

  def current_platform
    ENV['KONTENA_PLATFORM'] || current_master.name
  end
end