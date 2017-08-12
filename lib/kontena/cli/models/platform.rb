module Kontena::Cli::Models
  class Platform

    def initialize(api_data)
      @api_data = api_data
    end

    def id
      @api_data['id']
    end

    def region
      @api_data.dig('relationships', 'region', 'data', 'id')
    end

    def online?
      state.to_s == 'online'.freeze
    end

    def organization
      @api_data.dig('relationships', 'organization', 'data', 'id')
    end

    def method_missing(method, *args, &block)
      key = method.to_s.gsub('_', '-')
      if @api_data['attributes'].has_key?(key)
        @api_data['attributes'][key]
      else
        raise ArgumentError.new("Method `#{m}` doesn't exist.")
      end
    end
  end
end