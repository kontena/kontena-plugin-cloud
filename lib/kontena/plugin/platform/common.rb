module Kontena::Plugin::Platform::Common
  def fetch_platforms
    all = []
    organizations = cloud_client.get('/organizations')['data']
    organizations.each do |org|
      all = all + fetch_platforms_for_org(org['id'])
    end
    all
  end

  # @param [String] org_id
  # @return [Array<Hash>]
  def fetch_platforms_for_org(org_id)
    platforms = cloud_client.get("/organizations/#{org_id}/platforms")['data']
    platforms.map do |p|
      p['name'] = "#{org_id}/#{p.dig('attributes', 'name')}"
      p.merge({
        'name' => "#{org_id}/#{p.dig('attributes', 'name')}",
        'org_id' => org_id
      })
    end
  end

  # @return [String, NilClass]
  def current_organization
    @current_organization || ENV['KONTENA_ORGANIZATION'] || current_account.username
  end

  # @param [String] name
  def require_platform(name)
    unless name.include?('/')
      name = "#{current_organization}/#{name}"
    end
    org, platform = name.split('/')

    raise ArgumentError, "Organization missing" unless org

    @current_organization = org

    unless platform_config_exists?(name)
      platform = find_platform_by_name(platform, org)
      exit_with_error("Platform not found") unless platform

      if prompt.yes?("You are not logged in to platform #{name}, login now?")
      login_to_platform(name, platform.dig('attributes', 'url'))
      else
        exit_with_error('Cannot fetch platform info')
      end
    else
      self.current_master = name
      self.current_grid = platform
    end
  end

  def platform_config_exists?(name)
    !self.config.find_server_by(name: name).nil?
  end

  def find_platform_by_name(name, org)
    cloud_client.get("/organizations/#{org}/platforms")['data'].find { |p| p.dig('attributes', 'name') == name}
  end

  def login_to_platform(name, url)
    Kontena.run!(['master', 'login', '--silent', '--no-login-info', '--skip-grid-auto-select', '--name', name, url])
  end
end