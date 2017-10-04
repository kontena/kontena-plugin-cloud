require_relative 'common'

class Kontena::Plugin::Cloud::Platform::UpgradeCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  option "--version", "VERSION", "Upgrade to given version"

  def execute
    require_platform(name)

    platform = find_platform_by_name(current_platform, current_organization)
    unless version
      version = prompt_version(platform)
      if Gem::Version.new(version) < Gem::Version.new(platform.version)
        exit_with_error "Dowgrade is not supported"
      end
    end
    data = {
      attributes: {
        name: platform.name,
        version: platform.version
      }
    }
    cloud_client.put("/organizations/#{current_organization}/platforms/#{platform.name}", { data: data })
  end

  def prompt_version(platform)
    versions = cloud_client.get("/platform_versions")['data']

    platform_version = Gem::Version.new(platform.version)
    versions = versions.select { |v| Gem::Version.new(v['id']) >= platform_version }

    default_version = versions.find_index{ |v| v['id'] == platform.version } + 1
    prompt.select("Upgrade to version:") do |menu|
      menu.default default_version
      versions.each do |v|
        if v['id'] == platform.version
          menu.choice "#{v['id']} (redeploy)", v['id']
        else
          menu.choice v['id']
        end

      end
    end
  end
end