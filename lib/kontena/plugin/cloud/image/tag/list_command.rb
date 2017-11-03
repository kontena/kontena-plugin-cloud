require_relative '../common'

class Kontena::Plugin::Cloud::Image::Tag::ListCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Util
  include Kontena::Plugin::Cloud::Image::Common
  include Kontena::Cli::TableGenerator::Helper

  requires_current_account_token

  parameter "NAME", "Image repository name"

  def execute
    tags = image_registry_client.get("/repositories/#{name}/tags")['data']
    print_table(tags) do |t|
      t['id'] = "#{name}:#{t['id']}"
      t['pulls'] = t.dig('attributes', 'pulls')
      t['pushs'] = t.dig('attributes', 'pushs')
      t['updated_at'] = time_ago( Time.parse(t.dig('attributes', 'updated-at')).to_i )
    end
  end

  def fields
    {
      'name': 'id',
      'pulls': 'pulls',
      'pushes': 'pushs',
      'updated': 'updated_at'
    }
  end
end