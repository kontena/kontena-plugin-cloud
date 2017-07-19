class Kontena::Plugin::Cloud::Organization::User::AddCommand < Kontena::Command
  include Kontena::Cli::Common

  requires_current_account_token

  parameter "NAME", "Organization name"
  parameter "USERNAME ...", "List of usernames to add"

  option ["--role", "-r"], "ROLE", "Role to grant for users", default: "member"

  def execute
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
    username_list.each do |u|
      members << {
        type: 'users',
        id: u,
        meta: { role: role }
      }
    end
    spinner "Adding #{pastel.cyan(username_list.join(', '))} to organization #{pastel.cyan(name)} with role #{pastel.cyan(role)}" do
      data = {data: members}
      cloud_client.put("/organizations/#{name}/relationships/members", data)
    end
  end
end
