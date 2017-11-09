require_relative 'common'
class Kontena::Plugin::Cloud::Platform::WizardCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  INFRASTRUCTURE = {
    'cloud' => 'Kontena Cloud',
    'aws' => 'Amazon Web Services (EC2)',
    'digitalocean' => 'DigitalOcean',
    'vagrant' => 'Vagrant (with VirtualBox)'
  }

  parameter "[NAME]", "Platform name"
  option ['--organization', '--org'], 'ORG', 'Organization name', environment_variable: 'KONTENA_ORGANIZATION'
  option '--type', 'TYPE', 'Platform type (mini, standard)'
  option ['--region'], 'region', 'Region (us-east-1, eu-west-1)'
  option ['--initial-size', '-i'], 'SIZE', 'Initial size (number of nodes) for platform'
  option '--version', 'VERSION', 'Platform version', visible: false

  def execute
    exit_with_error "You don't have any supported plugins installed (#{INFRASTRUCTURE.keys.join(', ')})" if infrastucture_providers.empty?

    self.name = prompt.ask("Name:") unless self.name
    self.organization = prompt_organization unless self.organization
    self.type = prompt_type unless self.type
    self.region = prompt_region if self.region.nil? && self.type != 'mini'
    unless self.initial_size
      if self.type == 'mini'
        self.initial_size = 1
      else
        self.initial_size = 3
      end
    end

    platform = nil
    spinner "Creating platform master #{pastel.cyan(self.name)} to region #{pastel.cyan(self.region)}" do
      platform = create_platform(self.name, self.organization, self.initial_size, self.region, self.type)
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
    when 'cloud'
      create_cloud
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

  def prompt_type
    prompt.select("Platform type:") do |menu|
      menu.choice "standard (high-availability, business critical services)", "standard"
      menu.choice "mini (non-business critical services)", "mini"
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

  def create_platform(name, organization, initial_size, region, type)
    data = {
      attributes: { "name" => name, "initial-size" => initial_size, "hosted-type" => type },
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

  def create_cloud
    Kontena.run!([
      'cloud', 'node', 'create', '--count', self.initial_size
    ])
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