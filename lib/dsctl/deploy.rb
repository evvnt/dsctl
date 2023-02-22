module Dsctl
  class Deploy
    include Dsctl::Helpers::Logger
    VALID_TARGET_ENVIRONMENTS = %w[PROD DEV].freeze

    def initialize(schemas_path:, target_environment: ENV['TARGET_ENV'])
      unless VALID_TARGET_ENVIRONMENTS.include?(target_environment)
        raise "Invalid target environment: #{target_environment}. Valid environments are: #{VALID_TARGET_ENVIRONMENTS.join(', ')}"
      end

      @schemas_path = schemas_path
      @target_environment = target_environment
    end

    def call
      entities_map = Dsctl::SchemaFinder.new(schemas_path: @schemas_path).call

      @errors = []
      entities_map.each do |entity_name, versions|
        versions.each do |version, entity|
          next if entity['self']['vendor'] == 'com.snowplowanalytics.snowplow'
          begin
            schema = Dsctl::Schema.new(entity)
            deploy_schema!(schema)
          rescue StandardError => e
            report_error"We were unable to deploy #{entity_name} #{version} as #{e.message}"
          end
        end
      end

      raise "Schema deployment failed. Some errors were found" if @errors.any?
    end

    private

    def deploy_schema!(schema)
      schema_prefix = "Schema #{schema.entity_name} #{schema.version}:"
      deployment_msg = +"#{schema_prefix} Deploying to #{@target_environment} using dsctl"
      response = client.deploy_schema(schema, target_environment: @target_environment, message: deployment_msg)
      body = response.body

      logger.info "#{schema_prefix} Deploying"
      if response.success?
        if body['success'] == true
          logger.info "#{schema_prefix} was deployed successfully"
        elsif body['errors'] && body['errors'].is_a?(Array) && body['errors'].first.include?('already deployed')
          logger.warn "#{schema_prefix} was already deployed"
        else
          report_error "#{schema_prefix} unable to deploy as #{body['errors'].join(', ')}"
        end
      else
        report_error "#{schema_prefix} failed to deploy as #{response.status}, #{response.body}}"
      end

    end

    def client
      @client ||= Dsctl::Client.new
    end

    def report_error(error_message)
      logger.error error_message
      @errors << error_message
    end
  end
end
