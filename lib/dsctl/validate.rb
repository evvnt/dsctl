module Dsctl
  class Validate
    include Dsctl::Helpers::Logger

    def initialize(schemas_path:)
      @schemas_path = schemas_path
    end
      
    def call
      @errors = []

      entities_map = Dsctl::SchemaFinder.new(schemas_path: @schemas_path).call
      logger.info "Found #{entities_map.values.flatten.size} schemas to validate"
      entities_map.each do |entity_name, versions|
        versions.each do |version, entity|
          next if entity['self']['vendor'] == 'com.snowplowanalytics.snowplow'

          begin
            schema = Dsctl::Schema.new(entity)
            validate_schema!(schema)
          rescue StandardError => e
            report_error "We were unable to validate #{entity_name} #{version} as #{e.message}"
          end
        end
      end

      raise "Process failed. Some schemas didn't pass validation" if @errors.any?
    end

    private

    def validate_schema!(schema)
      response = client.validate_schema(schema)
      body = response.body
      schema_prefix = "Schema #{schema.entity_name} #{schema.version}:"
      logger.info "#{schema_prefix} Validating"

      if response.success?
        if body['success'] == true
          message = +"#{schema_prefix} is valid"
          if body['warnings'] && body['warnings'].any?
            message << " but has the following warnings: #{body['warnings'].join(', ')}"
          end

          logger.info message
        else
          report_error "#{schema_prefix} is not valid as #{body['errors'].join(', ')}"
        end
      else
        report_error "#{schema_prefix} unable to validate #{response.status}, #{response.body}}"
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
