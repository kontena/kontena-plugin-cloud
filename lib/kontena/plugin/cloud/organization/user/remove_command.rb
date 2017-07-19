class Kontena::Plugin::Cloud::Organization::User::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common

  requires_current_account_token

  parameter "NAME", "Organization name"
  parameter "USERNAME ...", "List of usernames to remove"

  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    confirm_command(username_list.join(',')) unless forced?

    members = []
    spinner "Resolving organization #{pastel.cyan(name)} current members" do
      members = cloud_client.get("/organizations/#{name}/members")['data']
      members = members.map { |m|
        {
          type: 'users',
          id: m.dig('attributes', 'username'),
          meta: {
            role: m.dig('attributes', 'role')
          }
        }
      }
    end
    members.delete_if { |m| username_list.include?(m[:id]) }
    spinner "Removing #{pastel.cyan(username_list.join(', '))} from organization #{pastel.cyan(name)}" do
      data = {data: members}
      cloud_client.put("/organizations/#{name}/relationships/members", data)
    end
  end
end
