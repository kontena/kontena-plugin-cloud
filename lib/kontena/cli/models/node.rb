require_relative 'cloud_api_model'

module Kontena::Cli::Models
  class Node
    include CloudApiModel

    def platform_id
      @api_data.dig('relationships', 'platform', 'data', 'id')
    end

    def organization_id
      @api_data.dig('relationships', 'organization', 'data', 'id')
    end
  end
end