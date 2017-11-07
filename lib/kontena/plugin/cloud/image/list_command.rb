require_relative 'common'

class Kontena::Plugin::Cloud::Image::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Util
  include Kontena::Plugin::Cloud::Image::Common
  include Kontena::Cli::TableGenerator::Helper

  option ["--organization", "--org"], "ORG", "Organization", environment_variable: "KONTENA_ORGANIZATION"

  requires_current_account_token

  def execute

    org = self.organization || default_org

    repos = image_registry_client.get("/organizations/#{org}/repositories")['data']
    print_table(repos) do |r|
      r['pulls'] = r.dig('attributes', 'pulls')
      r['created_at'] = time_ago( Time.parse(r.dig('attributes', 'created-at')).to_i )
    end
  end

  def fields
    {
      'name': 'id',
      'pulls': 'pulls',
      'created': 'created_at'
    }
  end
end
