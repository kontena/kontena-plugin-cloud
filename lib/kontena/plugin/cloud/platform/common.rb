require_relative '../../../cli/master_code_exchanger'
require_relative '../../../cli/models/platform'
require 'kontena/cli/master/login_command'

module Kontena::Plugin::Cloud::Platform::Common

  def cached_platforms
    @cached_platforms ||= []
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
    platforms = cloud_client.get("/organizations/#{org_id}/platforms")['data']
    platforms.map do |p|
      platform = Kontena::Cli::Models::Platform.new(p)
      cached_platforms << platform if cached_platforms.none?{|cached| platform.id == cached.id }
      platform
    end
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
    return p if ENV['KONTENA_PLATFORM'] == name
    unless platform_config_exists?(p.to_path)
      login_to_platform("#{current_organization}/#{platform}", p.url)
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

  # @param name [String]
  # @param org [String]
  # @param cache [Boolean]
  # @return [Kontena::Cli::Models::Platform, NilClass]
  def find_platform_by_name(name, org, cache = true)
    if cache && platform = cached_platforms.find{|p| p.name == name && p.organization == org }
      platform
    else
      data = cloud_client.get("/organizations/#{org}/platforms/#{name}")['data']
      if data
        platform = Kontena::Cli::Models::Platform.new(data)
        cached_platforms << platform
        platform
      end
    end
  end

  def login_to_platform(name, url)
    organization, platform = name.split('/')
    platform = find_platform_by_name(platform, organization)
    authorization = cloud_client.post("/organizations/#{organization}/masters/#{platform.master_id}/authorize", {})
    exchanger = Kontena::Cli::MasterCodeExchanger.new(platform.url)
    code = exchanger.exchange_code(authorization['code'])

    login = Kontena::Cli::Master::LoginCommand.new('kontena')
    cmd = [
      '--silent', '--no-login-info', '--skip-grid-auto-select',
      '--name', name, '--code', code, url
    ]
    login.run(cmd)
  rescue => e
    error e.message
  end
end