require_relative 'cloud_api_model'

module Kontena::Cli::Models
  class ImageTag
    include CloudApiModel

    def created_at
      Time.parse(@api_data.dig('attributes', 'created-at')).to_i
    end

    def updated_at
      Time.parse(@api_data.dig('attributes', 'updated-at')).to_i
    end
  end
end