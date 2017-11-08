require_relative 'common'
require 'shellwords'
require 'open3'

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
        output, stderr, status = Open3.capture3("docker login -u %s --password-stdin %s" % [current_account.username, image_distribution_url].map(&:shellescape), :stdin_data => pass)
        unless status.success?
          exit_with_error stderr
        end
      else
        pass = 'foo'
        output, stderr, status = Open3.capture3("docker login -u %s --password \"%s\" %s" % [current_account.username, pass, image_distribution_url])
        unless status.success?
          exit_with_error stderr
        end
      end
      true
    end

    if success
      puts
      puts "  Login succeeded. Now you should be able to push and pull images using docker"
      puts "  cli from #{pastel.cyan(image_distribution_url)}"
      puts
      puts "  Example:"
      puts
      puts "  #{pastel.green.on_black(' docker tag localimage images.kontena.io/organization/imagename ')}"
      puts "  #{pastel.green.on_black(' docker push images.kontena.io/organization/imagename           ')}"
      puts
      puts "  To configure grid nodes to pull from Kontena Cloud Image Registry you should:"
      puts
      puts "  1. Create a non-expiring token for authentication:"
      puts
      puts "     #{pastel.green.on_black(' kontena cloud token create <name> ')}"
      puts
      puts "  2. Configure your platform to use Kontena Cloud Image Registry as an external"
      puts "     registry:"
      puts
      puts "     #{pastel.green.on_black(' kontena external-registry add -u <username> -p <token> https://images.kontena.io ')}"
      puts
    end
  end
end
