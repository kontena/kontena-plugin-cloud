require_relative '../../../cli/master_code_exchanger'
require_relative '../../../cli/models/platform'

module Kontena::Plugin::Cloud::Platform::Common

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
    platforms = cloud_client.get("/organizations/#{org_id}/platforms")['data']
    platforms.map do |p|
      Kontena::Cli::Models::Platform.new(p)
    end
  end

  # @return [String, NilClass]
  def current_organization
    @current_organization || ENV['KONTENA_ORGANIZATION'] || (current_account && current_account.username)
  end

  def current_platform
    self.current_grid
  end

  # @param [String] name
  def require_platform(name)
    org, platform = parse_platform_name(name)

    @current_organization = org

    unless platform_config_exists?(name)
      p = find_platform_by_name(platform, org)
      exit_with_error("Platform not found") unless p

      login_to_platform(name, p.url)
    end
    self.current_master = name
    self.current_grid = platform
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
    data = cloud_client.get("/organizations/#{org}/platforms/#{name}")['data']
    if data
      Kontena::Cli::Models::Platform.new(data)
    end
  end

  def login_to_platform(name, url)
    organization, platform = name.split('/')
    platform = cloud_client.get("/organizations/#{organization}/platforms/#{platform}")['data']
    authorization = cloud_client.post("/organizations/#{organization}/masters/#{platform.dig('attributes', 'master-id')}/authorize", {})
    exchanger = Kontena::Cli::MasterCodeExchanger.new(platform.dig('attributes', 'url'))
    code = exchanger.exchange_code(authorization['code'])
    cmd = [
      'master', 'login', '--silent', '--no-login-info', '--skip-grid-auto-select',
      '--name', name, '--code', code, url
    ]
    Kontena.run!(cmd)
  end
end