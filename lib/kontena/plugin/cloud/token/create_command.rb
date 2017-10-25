class Kontena::Plugin::Cloud::Token::CreateCommand < Kontena::Command
  include Kontena::Cli::Common

  requires_current_account_token

  parameter "[NAME]", "Description for the personal access token"

  def execute
    self.name = prompt.ask("Name:") unless self.name
    data = { attributes: { name: self.name }}
    token = cloud_client.post("/user/personal_access_tokens", { data: data })['data']
    puts token.dig('attributes','access-token')
  end
end