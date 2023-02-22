require 'json'

module Dsctl
  class SchemaFinder
    include Dsctl::Helpers::Logger

    SELF_DESCRIBING_SCHEMA = 'http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#'.freeze

    def initialize(schemas_path:)
      @schemas_path = schemas_path
    end

    def call
      build_entities_map
    end

    def build_entities_map
      entities_map = {}

      schema_files_path.each do |path|
        begin
          file = JSON.parse(File.read(path))
          next unless file.dig('$schema') == SELF_DESCRIBING_SCHEMA

          entities_map[file['self']['name']]  = {} unless entities_map.key?(file['self']['name'])

          entities_map[file['self']['name']][file['self']['version']] = file
        rescue StandardError => e
          logger.error "We were unable to load file on #{path} as #{e.message}"
        end
      end

      entities_map
    end

    def schema_files_path
      Dir.glob(@schemas_path).select{ |fn| File.file?(fn) }
    end
  end
end
