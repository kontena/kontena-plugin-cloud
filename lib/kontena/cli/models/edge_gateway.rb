require_relative 'cloud_api_model'

module Kontena::Cli::Models
  class EdgeGateway
    include CloudApiModel

    def created_at
      Time.parse(@api_data.dig('attributes', 'created-at')).to_i
    end

    def platform_id
      @api_data.dig('relationships', 'platform', 'data', 'id')
    end

    def organization_id
      @api_data.dig('relationships', 'organization', 'data', 'id')
    end

    def node_ids
      @api_data.dig('relationships', 'nodes', 'data').map { |n| n['id'] }
    end
  end
end