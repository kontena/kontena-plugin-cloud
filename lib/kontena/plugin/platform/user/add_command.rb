class Kontena::Plugin::Platform::User::AddCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"
  parameter "[USERNAME] ...", "List of usernames to add"
  option ["--role", "-r"], "ROLE", "Role to grant for users"

  def execute
    require_platform(name)
    platform = find_platform_by_name(current_grid, current_organization)
    self.username_list = prompt_users(platform) if self.username_list.count == 0
    add_users(platform, username_list)
  end

  def prompt_users(platform)
    organization_members = cloud_client.get("/organizations/#{current_organization}/members")['data']
    platform_members = cloud_client.get("/organizations/#{current_organization}/platforms/#{platform.id}/relationships/users")['data']
    users = organization_members.map do |u|
      username = u.dig('attributes', 'username')
      if !platform_members.any?{|m| m['id'] == username }
        username
      end
    end.compact
    exit_with_error("All organization members are already added to platform") if users.size == 0
    prompt.multi_select("Choose users:") do |menu|
      users.each do |username|
        menu.choice username, username
      end
    end
  end

  def add_users(platform, usernames)
    users = []
    usernames.each do |u|
      user = {
        type: 'users',
        id: u
      }
      user[:meta] = { role: role } if role
      users << user
    end
    spinner "Adding users to platform #{pastel.cyan(name)}" do
      data = {data: users}
      cloud_client.post("/organizations/#{current_organization}/platforms/#{platform.id}/relationships/users", data)
    end
  end
end
