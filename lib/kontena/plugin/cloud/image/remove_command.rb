require_relative 'common'

class Kontena::Plugin::Cloud::Image::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Util
  include Kontena::Plugin::Cloud::Image::Common

  requires_current_account_token

  parameter "NAME", "Image repository name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    confirm_command(name) unless forced?

    spinner "Removing image repository #{pastel.cyan(name)}" do
      image_registry_client.delete("/repositories/#{name}")
    end
  end
end