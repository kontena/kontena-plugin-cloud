require_relative 'common'

class Kontena::Plugin::Cloud::Image::ShowCommand < Kontena::Command
  include Kontena::Cli::Common
  include Kontena::Util
  include Kontena::Plugin::Cloud::Image::Common

  requires_current_account_token

  parameter "NAME", "Image repository name"

  def execute
    repo = Kontena::Cli::Models::ImageRepo.new(image_registry_client.get("/repositories/#{name}")['data'])
    puts "#{name}:"
    puts "  created: #{ time_ago(repo.created_at.to_i)}"
    puts "  updated: #{ time_ago(repo.updated_at.to_i)}"
    puts "  pulls: #{repo.pulls}"
    puts "  pushs: #{repo.pushs}"
  end
end