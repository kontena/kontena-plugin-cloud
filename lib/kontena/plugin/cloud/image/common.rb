require_relative '../../../cli/models/image_repo'
require_relative '../../../cli/models/image_tag'
require_relative '../organization/common'

module Kontena::Plugin::Cloud::Image::Common
  include Kontena::Plugin::Cloud::Organization::Common

  def image_registry_client
    @compute_client ||= Kontena::Client.new(image_registry_url, config.current_account.token, prefix: '/')
  end

  def image_registry_url
    ENV['KONTENA_IMAGE_REGISTRY_URL'] || 'https://image-registry.kontena.io'
  end

  def image_distribution_url
    ENV['KONTENA_IMAGES_URL'] || 'https://images.kontena.io'
  end

  def default_org
    if current_master && current_master.name.include?('/')
      org, _ = current_master.name.split('/')
    else
      org = prompt_organization
    end

    org
  end
end