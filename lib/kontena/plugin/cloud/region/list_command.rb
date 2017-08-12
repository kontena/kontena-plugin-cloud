class Kontena::Plugin::Cloud::Region::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token

  def execute
    regions = cloud_client.get('/regions')['data']
    print_table(regions) do |row|
      row.merge!(row['attributes'])
    end
  end

  def fields
    {
      id: 'id',
      name: 'name'
    }
  end
end
