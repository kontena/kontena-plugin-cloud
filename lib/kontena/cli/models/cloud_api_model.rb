module Kontena::Cli::Models
  module CloudApiModel

    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data || {}
    end

    def id
      api_data['id']
    end

    def method_missing(method, *args, &block)
      key = method.to_s.gsub('_', '-')

      return api_data['attributes'].has_key?(key) && api_data['attributes'][key] if key.end_with?('?'.freeze)

      if api_data['attributes'].has_key?(key)
        api_data['attributes'][key]
      else
        super
      end
    end
  end
end