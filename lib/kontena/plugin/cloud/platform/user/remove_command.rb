require_relative '../common'

class Kontena::Plugin::Cloud::Platform::User::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Platform::Common

  requires_current_account_token

  parameter "NAME", "Platform name"
  parameter "[USERNAME] ...", "List of usernames to remove"

  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    require_platform(name)
    platform = find_platform_by_name(current_grid, current_organization)
    self.username_list = prompt_users(platform) if self.username_list.count == 0
    confirm_command(self.username_list.join(',')) unless forced?
    remove_users(platform, username_list)
  end

  def prompt_users(platform)
    platform_members = []
    spinner "Resolving organization #{pastel.cyan(name)} current users" do
       platform_members = cloud_client.get("/organizations/#{current_organization}/platforms/#{platform.id}/relationships/users")['data']
    end
    users = prompt.multi_select("Choose users:") do |menu|
      platform_members.each do |u|
        menu.choice u.dig('attributes', 'username'), u['id']
      end
    end
    if platform_members.size - users.size < 1
      exit_with_error "Cannot remove the last user of the platform"
    end
    users
  end

  def remove_users(platform, user_ids)
    users = []
    user_ids.each do |u|
      users << {
        type: 'users',
        id: u
      }
    end
    spinner "Removing users from platform #{pastel.cyan(name)}" do
      data = {data: users}
      cloud_client.delete("/organizations/#{current_organization}/platforms/#{platform.id}/relationships/users", data)
    end
  end
end
