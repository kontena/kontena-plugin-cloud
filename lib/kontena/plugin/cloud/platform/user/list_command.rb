require_relative '../common'

class Kontena::Plugin::Cloud::Platform::User::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token

  parameter "NAME", "Platform name"

  def execute
    require_platform(name)
    platform = find_platform_by_name(current_grid, current_organization)
    platform_users = cloud_client.get("/organizations/#{current_organization}/platforms/#{platform.id}/relationships/users")['data']
    print_table(platform_users) do |row|
      row.merge!(row['attributes'].merge(row['meta']))
    end
  end

  def fields
    {
      username: 'username',
      role: 'role'
    }
  end
end
