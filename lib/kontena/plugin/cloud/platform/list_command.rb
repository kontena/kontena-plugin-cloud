require_relative 'common'
require_relative '../organization/common'

class Kontena::Plugin::Cloud::Platform::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Plugin::Cloud::Organization::Common

  requires_current_account_token

  option ["--organization", "--org"], "ORG", "Organization", environment_variable: "KONTENA_ORGANIZATION"

  def execute
    platforms = cloud_client.get("/organizations/#{organization}/platforms")['data']

    print_table(platforms) do |p|
      platform = Kontena::Cli::Models::Platform.new(p)
      p['name'] = "#{state_icon(platform.state)} #{organization}/#{platform.name}"
      p['organization'] = platform.organization
      p['url'] = platform.url
      p['region'] = platform.region
    end
  end

  def default_organization
    prompt_organization
  end

  def fields
    {
      name: 'name',
      region: 'region'
    }
  end

  def state_icon(health)
    case health
    when nil
      " ".freeze
    when 'running'.freeze
      pastel.green('⊛'.freeze)
    else
      pastel.dark('⊝'.freeze)
    end
  end
end