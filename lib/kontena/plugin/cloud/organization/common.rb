require_relative '../../../cli/models/organization'

module Kontena::Plugin::Cloud::Organization::Common

  def fetch_organizations
    organizations = cloud_client.get("/organizations/")['data']
    organizations.map do |o|
      Kontena::Cli::Models::Organization.new(o)
    end
  end

  def prompt_organization
    organizations = fetch_organizations
    prompt.select("Choose organization") do |menu|
      organizations.each do |o|
        menu.choice o.name, o.name
      end
    end
  end

end