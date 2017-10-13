require 'excon'

class Kontena::Cli::MasterCodeExchanger
  class Error < StandardError
    attr_accessor :code

    def initialize(code, message)
      self.code = code
      super("#{code} #{message}")
    end
  end

  REDIRECT_URI = 'http://localhost/'.freeze

  # @param [String] url
  def initialize(url, ssl_verify_peer: false)
    @api_client = Excon.new(url, { ssl_verify_peer: ssl_verify_peer })
  end

  def exchange_code(authorization_code)
    master_auth_response = request_auth
    redirect_url = URI.parse(master_auth_response[:headers]['Location'])
    state = CGI.parse(redirect_url.query)['state']
    master_code_response = request_code(authorization_code, state.first)
    redirect_url = URI.parse(master_code_response[:headers]['Location'])
    CGI.parse(redirect_url.query)['code'].first
  end

  # @return [Hash]
  def request_auth
    params = {
      redirect_uri: REDIRECT_URI
    }
    response = execute("/authenticate?#{URI.encode_www_form(params)}")
    unless response[:status] == 302
      raise Error.new(response[:status], response[:data])
    end
    response
  end

  # @param [String] code
  # @param [String] state
  # @return [Hash]
  def request_code(code, state)
    params = {
      code: code,
      state: state
    }
    response = execute("/cb?#{URI.encode_www_form(params)}")
    unless response[:status] == 302
      raise Error.new(response[:status], response[:data])
    end
    response
  end

  private

  def execute(path, method = :get, payload = nil)
    headers = {}
    headers['Content-Type'] = 'application/json' unless payload.nil?

    body = payload.to_json if payload

    response = @api_client.request(method: method, body: body, path: path, headers: headers)
    content_type = response.headers.dig('Content-Type') || ''
    content_length = response.headers.dig('Content-Length').to_i
    body = if content_type.include?('json') && content_length > 0
      JSON.parse(response.body) rescue response.body
    else
      response.body
    end

    {
      status: response.status,
      headers: response.headers,
      data: body
    }
  end
end