require_relative 'common'

class Kontena::Plugin::Cloud::Image::CreateCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Util
  include Kontena::Plugin::Cloud::Image::Common
  include Kontena::Cli::TableGenerator::Helper

  parameter "NAME", "Image repository name"

  requires_current_account_token

  def execute

    body = {
      data: {
        type: 'repositories',
        id: self.name
      }
    }
    spinner "Creating image repository #{pastel.cyan(name)}" do
      image_registry_client.post("/repositories", body)
    end
  end

end
