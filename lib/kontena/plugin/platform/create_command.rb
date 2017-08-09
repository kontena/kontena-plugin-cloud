require_relative 'common'
class Kontena::Plugin::Platform::CreateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  option ['--organization'], 'ORG', 'Organization name', environment_variable: 'KONTENA_ORGANIZATION'
  option ['--region'], 'region', 'Region (us-east, eu-west)'
  option ['--initial-size', '-i'], 'SIZE', 'Initial size (number of nodes) for platform'
  option '--[no-]use', :flag, 'Switch to use created platform', default: true

  def execute
    confirm("This will create managed platform to Kontena Cloud, proceed?")

    self.name = prompt.ask("Name:") unless self.name
    self.organization = prompt_organization unless self.organization
    self.region = prompt_region unless self.region
    self.initial_size = prompt_initial_size unless self.initial_size

    platform = nil
    spinner "Creating platform #{pastel.cyan(name)} to region #{pastel.cyan(region)}" do
      platform = create_platform(name, organization, initial_size, region)['data']
    end
    spinner "Waiting for platform #{pastel.cyan(name)} to come online" do
      while !platform.online? do
        sleep 5
        platform = find_platform_by_name(platform.id, organization)
      end
    end
    use_platform(platform) if use?
  end

  # @param [Kontena::Cli::Models::Platform] platform
  def use_platform(platform)
    platform_name = "#{organization}/#{name}"
    login_to_platform(platform_name, platform.dig('attributes', 'url'))
    spinner "Switching to use platform #{pastel.cyan(platform_name)}" do
      config.current_grid = name
      config.write
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
    data = cloud_client.post("/organizations/#{organization}/platforms", { data: data })['data']
    Kontena::Cli::Models::Platform.new(data)
  end
end