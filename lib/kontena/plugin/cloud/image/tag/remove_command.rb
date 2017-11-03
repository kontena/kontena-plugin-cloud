require_relative '../common'

class Kontena::Plugin::Cloud::Image::Tag::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Image::Common

  requires_current_account_token

  parameter "NAME", "Image repository name"
  parameter "TAG ...", "Tag name"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    confirm_command(name) unless forced?

    spinner "Remove tag(s) #{tag_list.join(',')} from repository #{name}" do
      tag_list.each do |tag|
        image_registry_client.delete("/repositories/#{name}/tags/#{tag}")
      end
    end
  end
end