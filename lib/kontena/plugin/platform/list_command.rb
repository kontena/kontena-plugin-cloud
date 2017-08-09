require_relative 'common'

class Kontena::Plugin::Platform::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "[ORG]", "Organization name", environment_variable: "KONTENA_ORGANIZATION"

  def execute
    platforms = cloud_client.get("/organizations/#{org}/platforms")['data']

    print_table(platforms) do |p|
      platform = Kontena::Cli::Models::Platform.new(p)
      p['name'] = "#{state_icon(platform.state)} #{org}/#{platform.name}"
      p['organization'] = platform.organization
      p['url'] = platform.url
      p['region'] = platform.region
    end
  end

  def default_org
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
    when 'online'.freeze
      pastel.green('⊛'.freeze)
    else
      pastel.dark('⊝'.freeze)
    end
  end
end