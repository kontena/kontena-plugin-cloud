class Kontena::Plugin::Cloud::Organization::User::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token

  parameter "NAME", "Organization name"

  def execute
    members = cloud_client.get("/organizations/#{name}/members")['data']
    print_table(members) do |row|
      row.merge!(row['attributes'])
    end
  end

  def fields
    {
      username: 'username',
      role: 'role'
    }
  end
end
