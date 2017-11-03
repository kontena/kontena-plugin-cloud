require_relative '../../../cli/models/image_repo'
require_relative '../../../cli/models/image_tag'

module Kontena::Plugin::Cloud::Image::Common
  def image_registry_client
    @compute_client ||= Kontena::Client.new(image_registry_url, config.current_account.token, prefix: '/')
  end

  def image_registry_url
    ENV['IMAGE_REGISTRY_URL'] || 'https://image-registry.kontena.io'
  end

  def image_distribution_url
    ENV['IMAGE_DISTRIBUTION_URL'] || 'https://image.kontena.io'
  end

  def default_organization
    unless current_master
      exit_with_error "Organization is required"
    end
    org, _ = current_master.name.split('/')
    org
  end
end