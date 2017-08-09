class Kontena::Plugin::Platform::ImportGridCommand < Kontena::Command
  include Kontena::Cli::Common

  banner "Migrate grid to Kontena Cloud platform"

  parameter "MASTER", "Kontena Master name in local config"
  parameter "GRID", "Grid name"
  parameter "PLATFORM", "Platform name"

  option "--organization", "ORG", "Organization name"

  requires_current_account_token

  def execute
    self.organization = prompt_organization unless self.organization

    master = config.find_server(self.master)
    if master.nil?
      exit_with_error "Could not resolve master by name '#{self.master}'." +
            "\nFor a list of known masters please run: kontena master list"
    else
      config.current_master = master['name']
    end
    config.current_master.grid = self.grid

    grid = client.get("/v1/grids/#{self.grid}")
    attributes = {
      'name' => self.platform,
      'grid' => self.grid,
      'url' => current_master.url,
      'initial-size' => grid['initial_size']
    }
    spinner "Migrating #{self.master}/#{self.grid} (#{current_master.url}) to Kontena Cloud organization #{organization}" do
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