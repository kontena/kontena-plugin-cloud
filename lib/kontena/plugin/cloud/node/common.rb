require_relative '../../../cli/models/node'
require_relative '../../../cli/models/platform'
require_relative 'platform_option'

module Kontena::Plugin::Cloud::Node::Common

  def compute_client
    @compute_client ||= Kontena::Client.new(compute_url, config.current_account.token, prefix: '/')
  end

  def config
    Kontena::Cli::Config.instance
  end

  def compute_url
    ENV['KONTENA_COMPUTE_URL'] || 'https://compute.kontena.io'
  end

  def get_platform(org, id)
    unless cached_platforms_by_id[id]
      data = cloud_client.get("/organizations/#{org}/platforms/#{id}")['data']
      if data
        platform = Kontena::Cli::Models::Platform.new(data)
        cached_platforms_by_id[id] = platform
      end
    end

    cached_platforms_by_id[id]
  end

  def cached_platforms_by_id
    @cached_platforms_by_id ||= {}
  end
end