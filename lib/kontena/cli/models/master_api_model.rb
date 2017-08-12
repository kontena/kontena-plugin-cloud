module Kontena::Cli::Models
  module MasterApiModel

    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data || {}
    end

    def method_missing(method, *args, &block)
      key = method.to_s

      return @api_data.has_key?(key) && @api_data[key] if key.end_with?('?'.freeze)

      if @api_data.has_key?(key)
        @api_data[key]
      else
        raise ArgumentError.new("Method `#{m}` doesn't exist.")
      end
    end
  end
end