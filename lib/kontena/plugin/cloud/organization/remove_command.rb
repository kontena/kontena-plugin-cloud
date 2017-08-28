class Kontena::Plugin::Cloud::Organization::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common

  parameter "NAME", "Organization name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  requires_current_account_token

  def execute
    confirm_command(name) unless forced?

    spinner "Removing organization #{pastel.cyan(name)}" do
      cloud_client.delete("/organizations/#{name}")
    end
  end
end
