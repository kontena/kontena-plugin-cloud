class Kontena::Plugin::Platform::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token

  def execute
    all_platforms = []
    organizations = cloud_client.get('/organizations')['data']
    organizations.each do |org|
      platforms = cloud_client.get("/organizations/#{org['id']}/platforms")['data']
      platforms.each do |p|
        p['organization'] = org
        all_platforms << p
      end
    end

    print_table(all_platforms) do |p|
      p['name'] = "#{state_icon(p.dig('attributes', 'state'))} #{p.dig('organization', 'id')}/#{p.dig('attributes', 'name')}"
      p['organization'] = p.dig('organization', 'id')
      p['url'] = p.dig('attributes', 'url')
      p['datacenter'] = p.dig('relationships', 'datacenter', 'data', 'id')
    end
  end

  def fields
    {
      name: 'name',
      organization: 'organization',
      datacenter: 'datacenter'
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