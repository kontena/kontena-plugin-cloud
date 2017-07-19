class Kontena::Plugin::Cloud::Organization::ShowCommand < Kontena::Command
  include Kontena::Cli::Common

  parameter "NAME", "Organization name"

  requires_current_account_token

  def execute
    org = cloud_client.get("/organizations/#{name}").dig('data', 'attributes')
    puts "#{org['name']}:"
    puts "  email: #{org['email']}"
    puts "  your role: #{org['owner'] ? 'owner' : 'member'}"
    puts "  url: #{org['url'] || '-'}"
    puts "  location: #{org['location'] || '-'}"
  end
end
