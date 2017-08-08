class Kontena::Plugin::Grid::PlatformMigrateCommand < Kontena::Command
  include Kontena::Cli::Common

  banner "Migrate grid to Kontena Cloud platform"

  parameter "NAME", "Grid name"
  parameter "PLATFORM", "Platform name"

  option "--organization", "ORG", "Organization name"

  requires_current_master_token
  requires_current_account_token

  def execute
    self.organization = prompt_organization unless self.organization
    grid = client.get("/v1/grids/#{name}")
    attributes = {
      'name' => platform,
      'grid' => name,
      'url' => current_master.url,
      'initial-size' => grid['initial_size']
    }
    spinner "Migrating #{name} (#{current_master.url}) to Kontena Cloud organization #{organization}" do
      cloud_client.post("/organizations/#{organization}/platforms/migrate", { data: { attributes: attributes } })
    end
  end

  def prompt_organization
    organizations = cloud_client.get('/organizations')['data']
    prompt.select("Choose organization:") do |menu|
      menu.choice "#{config.current_account.username} (you)", config.current_account.username
      organizations.each do |o|
        menu.choice o.dig('attributes', 'name')
      end
    end
  end
end