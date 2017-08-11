class Kontena::Plugin::Cloud::Organization::User::AddCommand < Kontena::Command
  include Kontena::Cli::Common

  requires_current_account_token

  parameter "NAME", "Organization name"
  parameter "USERNAME ...", "List of usernames to add"

  option ["--role", "-r"], "ROLE", "Role to grant for users", default: "member"

  def execute
    members = []
    username_list.each do |u|
      members << {
        type: 'users',
        id: u,
        meta: { role: role }
      }
    end
    spinner "Adding #{pastel.cyan(username_list.join(', '))} to organization #{pastel.cyan(name)} with role #{pastel.cyan(role)}" do
      data = {data: members}
      cloud_client.post("/organizations/#{name}/relationships/members", data)
    end
  end
end
