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
    spinner "Provisioning an edge gateway #{pastel.cyan(name)} to platform #{pastel.cyan(platform.to_path)}, region #{pastel.cyan(target_region)}" do
      compute_client.post("/organizations/#{current_organization}/edge-gateways", { data: data })
    end
  end

  def current_platform
    ENV['KONTENA_PLATFORM'] || current_master.name
  end
end