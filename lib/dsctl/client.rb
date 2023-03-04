require_relative 'adapters/http_adapter'

module Dsctl
  class Client
    BASE_URI = 'https://console.snowplowanalytics.com/api/msc/v1/organizations'.freeze
    attr_reader :conn

    def initialize(organization_id: ENV['ORGANIZATION_ID'], api_key: ENV['API_KEY'])
      @api_key = api_key
      @conn = Faraday.new(url: "#{BASE_URI}/#{organization_id}") do |f|
        f.request :json
        f.response :json
        if ENV['DEBUG_MODE'] == 'true'
          f.response :logger, nil, {
            bodies: true,
            log_level: :debug
          }
        end
      end

      authenticate!
    end

    def validate_schema(schema)
      conn.post('data-structures/v1/validation-requests', {
        # This meta object is required by the API, but it's ignored, so we are just passing default values
        meta: {
          hidden: false,
          schemaType: 'entity',
          customData: {}
        },
        data: schema.to_h
      }.to_json)
    end

    def deploy_schema(schema, target_environment:, message:)
      params = {
        message: message,
        source: target_environment == 'PROD' ? 'DEV' : 'VALIDATED',
        target: target_environment,
        vendor: schema.dig('self', 'vendor'),
        name: schema.dig('self', 'name'),
        format: schema.dig('self', 'format'),
        version: schema.dig('self', 'version')
      }

      conn.post('data-structures/v1/deployment-requests', params.to_json)
    end

    private

    def authenticate!
      response = conn.get('credentials/v2/token', nil, { 'X-API-Key' => @api_key })

      if response.success?
        conn.headers['Authorization'] = "Bearer #{response.body['accessToken']}"
      else
        raise "Error authenticating: #{response.body}"
      end
    end
  end
end
