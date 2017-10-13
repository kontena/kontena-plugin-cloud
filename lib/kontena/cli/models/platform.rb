require_relative 'cloud_api_model'

module Kontena::Cli::Models
  class Platform
    include CloudApiModel

    def region
      @api_data.dig('relationships', 'region', 'data', 'id')
    end

    def online?
      state.to_s == 'online'.freeze
    end

    def organization
      @api_data.dig('relationships', 'organization', 'data', 'id')
    end

    def to_path
      "#{self.organization}/#{self.name}"
    end
  end
end