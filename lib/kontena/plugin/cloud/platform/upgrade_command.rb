require_relative 'common'

class Kontena::Plugin::Cloud::Platform::UpgradeCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"

  option "--version", "VERSION", "Upgrade to given version"

  def execute
    require_platform(name)

    to_version = self.version
    platform = find_platform_by_name(current_platform, current_organization)
    unless to_version
      to_version = prompt_version(platform)
      if Gem::Version.new(to_version) < Gem::Version.new(platform.version)
        exit_with_error "Downgrade is not supported"
      end
    end
    data = {
      attributes: {
        name: platform.name,
        version: to_version
      }
    }
    spinner "Upgrading platform #{pastel.cyan(name)} to version #{to_version}" do
      cloud_client.put("/organizations/#{current_organization}/platforms/#{platform.name}", { data: data })
      while platform.version != to_version do
        sleep 5
        platform = find_platform_by_name(platform.id, current_organization, false)
      end
    end
  end

  # @param platform [Platform]
  def prompt_version(platform)
    versions = cloud_client.get("/platform_versions")['data']

    platform_version = Gem::Version.new(platform.version)
    versions = versions.select { |v| Gem::Version.new(v['id']) > platform_version }

    exit_with_error "Platform is already on the latest version" if versions.size == 0

    prompt.select("Upgrade to version:") do |menu|
      versions.each do |v|
        menu.choice v['id']
      end
    end
  end
end