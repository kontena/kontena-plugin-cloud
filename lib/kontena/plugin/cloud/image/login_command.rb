require_relative 'common'

class Kontena::Plugin::Cloud::Image::LoginCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Plugin::Cloud::Image::Common

  requires_current_account_token

  def execute
    token = nil
    spinner "Creating a new Kontena Cloud token for Docker" do
      data = { attributes: { name: 'docker' } }
      token = cloud_client.post("/user/personal_access_tokens", { data: data })['data']
    end

    success = nil
    spinner "Logging in to the Kontena Cloud Image Registry" do
      success = system("echo '#{token.dig('attributes', 'access-token')}' | docker login -u #{current_account.username} --password-stdin #{image_distribution_url} > /dev/null")
    end
    if success
      puts ""
      puts "  Login succeeded, you should now able to push and pull images using docker cli from #{image_distribution_url}"
      puts ""
      puts "  To configure grid nodes to be able to pull from Kontena Cloud Image Registry you must:"
      puts "  1. Create non-expiring token for authentication: kontena cloud token create <name>"
      puts "  2. Configure your platform to use Kontena Cloud Image Registry as external registry:"
      puts "     kontena external-registry add -e <email> -u <username> -p <token> https://images.kontena.io"
      puts ""
    end
  end
end
