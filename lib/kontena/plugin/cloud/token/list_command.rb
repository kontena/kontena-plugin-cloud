class Kontena::Plugin::Cloud::Token::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token

  def execute
    tokens = cloud_client.get('/user/personal_access_tokens')['data']
    print_table(tokens) do |row|
      row.merge!(row['attributes'])
    end
  end

  def fields
    {
      id: 'id',
      created: 'created-at',
      name: 'name'
    }
  end
end
