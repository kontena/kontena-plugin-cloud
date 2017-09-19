require_relative '../../../cli/master_code_exchanger'
require_relative '../../../cli/models/platform'

module Kontena::Plugin::Cloud::Platform::Common

  def platforms
    @platforms ||= {}
  end

  def fetch_platforms
    all = []
    organizations = cloud_client.get('/organizations')['data']
    organizations.each do |org|
      all = all + fetch_platforms_for_org(org['id'])
    end
    all
  end

  # @param [String] org_id
  # @return [Array<Kontena::Cli::Models::Platform>]
  def fetch_platforms_for_org(org_id)
    return platforms[org_id] if platforms[org_id]

    org_platforms = cloud_client.get("/organizations/#{org_id}/platforms")['data']
    platforms[org_id] = org_platforms.map do |p|
      Kontena::Cli::Models::Platform.new(p)
    end

    platforms[org_id]
  end

  def prompt_platform
    platforms = fetch_platforms_for_org(current_organization)
    prompt.select("Choose platform") do |menu|
      platforms.each do |p|
        menu.choice p.name, p
      end
    end
  end

  # @return [String, NilClass]
  def current_organization
    @current_organization || ENV['KONTENA_ORGANIZATION']
  end

  def current_platform
    self.current_grid
  end

  # @param [String] name
  def require_platform(name)
    org, platform = parse_platform_name(name)
    @current_organization = org
    p = find_platform_by_name(platform, org)
    exit_with_error("Platform not found") unless p
    unless platform_config_exists?(p.to_path)
      spinner "Generating platform token" do
        login_to_platform("#{current_organization}/#{platform}", p.url)
      end
    end
    self.current_master = "#{current_organization}/#{platform}"
    self.current_grid = p.grid_id
    p
  end

  # @param [String] name
  # @return [Array<String>] organization, platform
  def parse_platform_name(name)
    unless name.include?('/')
      name = "#{current_organization}/#{name}"
    end
    org, platform = name.split('/')

    raise ArgumentError, "Organization missing" unless org

    [org, platform]
  end

  def platform_config_exists?(name)
    !self.config.find_server_by(name: name).nil?
  end

  def find_platform_by_name(name, org)
    if platforms[org]
      platforms[org].find{|p| p.name == name }
    else
      data = cloud_client.get("/organizations/#{org}/platforms/#{name}")['data']
      if data
        Kontena::Cli::Models::Platform.new(data)
      end
    end
  end

  def login_to_platform(name, url)
    organization, platform = name.split('/')
    platform = find_platform_by_name(platform, organization)
    authorization = cloud_client.post("/organizations/#{organization}/masters/#{platform.master_id}/authorize", {})
    exchanger = Kontena::Cli::MasterCodeExchanger.new(platform.url)
    code = exchanger.exchange_code(authorization['code'])
    cmd = [
      'master', 'login', '--silent', '--no-login-info', '--skip-grid-auto-select',
      '--name', name, '--code', code, url
    ]
    Kontena.run!(cmd)
  rescue => e
    error e.message
  end
end