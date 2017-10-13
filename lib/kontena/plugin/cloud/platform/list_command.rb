require_relative 'common'

class Kontena::Plugin::Cloud::Platform::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper
  include Kontena::Plugin::Cloud::Platform::Common

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
    current_account.username
  end

  def fields
    {
      name: 'name',
      organization: 'organization',
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