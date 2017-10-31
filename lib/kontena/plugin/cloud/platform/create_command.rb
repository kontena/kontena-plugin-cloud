require_relative 'common'
class Kontena::Plugin::Cloud::Platform::CreateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  parameter "[NAME]", "Platform name"

  option ['--organization', '--org'], 'ORG', 'Organization name', environment_variable: 'KONTENA_ORGANIZATION'
  option ['--type'], 'TYPE', 'Platform type (mini, standard)'
  option ['--region'], 'region', 'Region (us-east-1, eu-west-1)'
  option ['--initial-size', '-i'], 'SIZE', 'Initial size (number of nodes) for platform'
  option '--[no-]use', :flag, 'Switch to use created platform', default: true
  option '--version', 'VERSION', 'Platform version', visible: false

  def execute
    self.name = prompt.ask("Name:") unless self.name
    self.organization = prompt_organization unless self.organization
    self.type = prompt_type unless self.type
    if self.type == 'mini' && self.region
      exit_with_error "mini does not support region selection"
    elsif self.type == 'mini'
      self.region = nil
      self.initial_size = 1 unless self.initial_size
    else
      self.region = prompt_region unless self.region
      self.initial_size = 3 unless self.initial_size
    end

    platform = nil
    spinner_text = "Creating platform #{pastel.cyan(name)}"
    spinner_text = spinner_text + " to region #{pastel.cyan(region)}" if region
    spinner spinner_text do
      platform = create_platform(name, organization, type, initial_size, region)
    end
    spinner "Waiting for platform #{pastel.cyan(name)} to come online" do
      while !platform.online? do
        sleep 5
        platform = find_platform_by_name(platform.id, organization)
      end
    end
    use_platform(platform) if use?

    puts ""
    puts "  Platform #{pastel.cyan(name)} needs at least #{pastel.cyan(self.initial_size)} node(s) to be functional."
    puts "  You can add nodes from Kontena Cloud ('kontena cloud node create --count #{self.initial_size}') or you can bring your own nodes (https://www.kontena.io/docs/using-kontena/install-nodes/)."
    puts ""
  end

  # @param [Kontena::Cli::Models::Platform] platform
  def use_platform(platform)
    platform_name = "#{organization}/#{name}"
    login_to_platform(platform_name, platform.url)
    spinner "Switching to use platform #{pastel.cyan(platform_name)}" do
      config.current_grid = name
      config.write
    end
  end

  def prompt_organization
    organizations = cloud_client.get('/organizations')['data']
    prompt.select("Choose organization:") do |menu|
      organizations.each do |o|
        menu.choice o.dig('attributes', 'name')
      end
    end
  end

  def prompt_region
    regions = cloud_client.get('/regions')['data']
    prompt.select("Choose region:") do |menu|
      regions.each do |d|
        menu.choice d.dig('attributes', 'name'), d['id']
      end
    end
  end

  def prompt_type
    prompt.select("Platform type:") do |menu|
      menu.choice "standard (high-availability, business critical services)", "standard"
      menu.choice "mini (non-business critical services)", "mini"
    end
  end

  def create_platform(name, organization, type, initial_size, region)
    data = {
      attributes: {
        "name" => name,
        "initial-size" => initial_size,
        "hosted-type" => type
      },
      relationships: {
        region: {
          "data" => { "type" => "region", "id" => region }
        }
      }
    }
    data[:attributes]['version'] = self.version if self.version
    data = cloud_client.post("/organizations/#{organization}/platforms", { data: data })['data']
    Kontena::Cli::Models::Platform.new(data)
  end
end