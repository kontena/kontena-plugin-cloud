class Kontena::Plugin::Platform::CreateCommand < Kontena::Command
  include Kontena::Cli::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  option ['--organization'], 'ORG', 'Organization name'
  option ['--region'], 'region', 'Region (us-east, eu-west)'
  option ['--initial-size', '-i'], 'SIZE', 'Initial size (number of nodes) for platform'

  def execute
    confirm("This will create managed platform to Kontena Cloud, proceed?")

    name = prompt.ask("Name:") unless self.name
    organization = prompt_organization unless self.organization
    region = prompt_region unless self.region
    initial_size = prompt_initial_size unless self.initial_size

    platform = nil
    spinner "Creating platform #{pastel.cyan(name)} to region #{pastel.cyan(region)}" do
      platform = create_platform(name, organization, initial_size, region)
    end
    spinner "Waiting for platform #{pastel.cyan(name)} to come online" do
      online = false
      while !online do
        sleep 5
        data = cloud_client.get("/organizations/#{organization}/platforms/#{platform.dig('data', 'id')}")['data']
        online = data.dig('attributes', 'state') == 'online'
      end
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

  def prompt_region
    datacenters = cloud_client.get('/datacenters')['data']
    prompt.select("Choose region:") do |menu|
      datacenters.each do |d|
        menu.choice d.dig('attributes', 'name'), d['id']
      end
    end
  end

  def prompt_initial_size
    prompt.select("Initial platform size (number of nodes):") do |menu|
      menu.choice "1 (dev/test)", 1
      menu.choice "3 (tolerates 1 initial node failure)", 3
      menu.choice "5 (tolerates 2 initial node failures)", 5
    end
  end

  def create_platform(name, organization, initial_size, region)
    data = {
      attributes: { "name": name, "initial-size": initial_size },
      relationships: {
        datacenter: {
          "data": { "type": "datacenters", "id": region }
        }
      }
    }
    cloud_client.post("/organizations/#{organization}/platforms", { data: data })
  end
end