require_relative 'common'
class Kontena::Plugin::Cloud::Platform::WizardCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  INFRASTRUCTURE = {
    'aws' => 'Amazon Web Services (EC2)',
    'digitalocean' => 'DigitalOcean',
    'vagrant' => 'Vagrant (with VirtualBox)'
  }

  parameter "[NAME]", "Platform name"
  option ['--organization', '--org'], 'ORG', 'Organization name', environment_variable: 'KONTENA_ORGANIZATION'
  option ['--region'], 'region', 'Region (us-east-1, eu-west-1)'
  option ['--initial-size', '-i'], 'SIZE', 'Initial size (number of nodes) for platform'
  option '--version', 'VERSION', 'Platform version', visible: false

  def execute
    exit_with_error "You don't have any supported plugins installed (#{INFRASTRUCTURE.keys.join(', ')})" if infrastucture_providers.empty?

    self.name = prompt.ask("Name:") unless self.name
    self.organization = prompt_organization unless self.organization
    self.region = prompt_region unless self.region
    self.initial_size = prompt_initial_size unless self.initial_size

    platform = nil
    spinner "Creating platform master #{pastel.cyan(name)} to region #{pastel.cyan(region)}" do
      platform = create_platform(name, organization, initial_size, region)
    end
    spinner "Waiting for platform master #{pastel.cyan(name)} to come online" do
      while !platform.online? do
        sleep 5
        platform = find_platform_by_name(platform.id, organization)
      end
    end
    use_platform(platform)

    infra = prompt.select("Choose infrastructure provider for platform nodes") do |menu|
      INFRASTRUCTURE.each do |id, name|
        menu.choice name, id
      end
    end

    case infra
    when 'aws'
      create_aws
    when 'digitalocean'
      create_digitalocean
    when 'upcloud'
      create_upcloud
    when 'vagrant'
      create_vagrant
    end

    spinner "Platform #{pastel.cyan(platform.name)} is now ready!"
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

  def prompt_initial_size
    prompt.select("Initial platform size (number of nodes):") do |menu|
      menu.choice "1 (dev/test)", 1
      menu.choice "3 (tolerates 1 initial node failure)", 3
      menu.choice "5 (tolerates 2 initial node failures)", 5
    end
  end

  def create_platform(name, organization, initial_size, region)
    data = {
      attributes: { "name" => name, "initial-size" => initial_size },
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

  def create_vagrant
    Kontena.run!([
      'vagrant', 'node', 'create', '--version', self.version, '--instances', self.initial_size
    ])
  end

  def create_aws
    Kontena.run!([
      'aws', 'node', 'create',
      '--version', self.version,
      '--count', self.initial_size,
      '--region', self.region
    ])
  end

  def create_digitalocean
    do_region = case self.region
    when 'eu-west-1'
      'lon1'
    when 'us-east-1'
      'nyc1'
    end

    Kontena.run!([
      'digitalocean', 'node', 'create',
      '--version', self.version,
      '--count', self.initial_size,
      '--channel', 'stable',
      '--region', do_region
    ])
  end

  def infrastucture_providers
    if @infrastucture_providers.nil?
      main_commands = Kontena::MainCommand.recognised_subcommands.flat_map(&:names)
      @infrastucture_providers = INFRASTRUCTURE.dup.delete_if { |k, v| !main_commands.include?(k) }
    end
    @infrastucture_providers
  end
end