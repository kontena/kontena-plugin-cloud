require_relative 'master_api_model'

module Kontena::Cli::Models
  class Grid
    include MasterApiModel

    class Stats
      include MasterApiModel

      Statsd = Struct.new(:server, :port)

      def statsd
        @statsd ||= Statsd.new(@api_data.dig('statsd', 'server'), @api_data.dig('statsd', 'port'))
      end
    end

    class Logs
      include MasterApiModel
    end

    def id
      api_data['id']
    end

    def logs
      @logs ||= Logs.new(api_data['logs'])
    end

    def stats
      @stats ||= Stats.new(api_data['stats'])
    end
  end
end