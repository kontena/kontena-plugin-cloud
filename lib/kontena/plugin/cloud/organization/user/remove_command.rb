class Kontena::Plugin::Cloud::Organization::User::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common

  requires_current_account_token

  parameter "NAME", "Organization name"
  parameter "USERNAME ...", "List of usernames to remove"

  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    confirm_command(username_list.join(',')) unless forced?

    members = []
    username_list.each do |u|
      members << {
        type: 'users',
        id: u
      }
    end
    spinner "Removing #{pastel.cyan(username_list.join(', '))} from organization #{pastel.cyan(name)}" do
      data = {data: members}
      cloud_client.delete("/organizations/#{name}/relationships/members", data)
    end
  end
end
