require_relative 'common'
require 'shellwords'

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

    success = spinner "Logging in to the Kontena Cloud Image Registry" do |spin|
      pass = token.dig('attributes', 'access-token')

      if `docker login --help`['--password-stdin']
        system("echo '%s' | docker login -u %s --password-stdin %s > /dev/null" % [pass, current_account.username, image_distribution_url].map(&:shellescape)) || spin.fail
      else
        system("docker login -u %s --password %s %s > /dev/null" % [current_account.username, pass, image_distribution_url].map(&:shellescape)) || spin.fail
      end
    end

    if success
      puts
      puts "  Login succeeded. Now you should be able to push and pull images using docker cli from #{pastel.cyan(image_distribution_url)}"
      puts "  To configure grid nodes to be able to pull from Kontena Cloud Image Registry you should:"
      puts
      puts "  1. Create a non-expiring token for authentication: #{pastel.green.on_black(' kontena cloud token create <name> ')}"
      puts "  2. Configure your platform to use Kontena Cloud Image Registry as an external registry:"
      puts "     #{pastel.green.on_black(' kontena external-registry add -e <email> -u <username> -p <token> https://images.kontena.io ')}"
      puts
    end
  end
end
