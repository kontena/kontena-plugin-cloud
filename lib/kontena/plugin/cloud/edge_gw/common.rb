require_relative '../../../cli/models/node'
require_relative '../../../cli/models/platform'
require_relative '../../../cli/models/edge_gateway'

module Kontena::Plugin::Cloud::EdgeGw::Common

  def compute_client
    @compute_client ||= Kontena::Client.new(compute_url, config.current_account.token, prefix: '/')
  end

  def config
    Kontena::Cli::Config.instance
  end

  def compute_url
    ENV['KONTENA_COMPUTE_URL'] || 'https://compute.kontena.io'
  end
end