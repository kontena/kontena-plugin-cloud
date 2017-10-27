class Kontena::Plugin::Cloud::Token::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token
  parameter "[ID]", "ID of the token"
  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    id = self.id
    confirm unless forced?
    cloud_client.delete("/user/personal_access_tokens/#{id}")
  end


  def prompt_token
    tokens = cloud_client.get('/user/personal_access_tokens')['data']
    prompt.select("Choose token:") do |menu|
      tokens.each do |d|
        menu.choice d.dig('attributes', 'name'), d['id']
      end
    end
  end

  def default_id
    prompt_token
  end
end
