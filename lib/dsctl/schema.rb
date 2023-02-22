module Dsctl
  class Schema
    attr_reader :schema_hash

    def initialize(schema_hash)
      @schema_hash = schema_hash
    end

    def entity_name
      schema_hash.dig('self', 'name')
    end

    def version
      schema_hash.dig('self', 'version')
    end

    def to_h
      schema_hash
    end

    def [](key)
      schema_hash[key]
    end

    def dig(*keys)
      schema_hash.dig(*keys)
    end

    def schema_encoded_hash
      structure_hash = {
        organization_id: ENV['ORGANIZATION_ID'],
        vendor: schema_hash.dig('self', 'vendor'),
        schema_name: schema_hash.dig('self', 'name'),
        format: schema_hash.dig('self', 'format')
      }

      Digest::SHA256.hexdigest(structure_hash.values.join('-'))
    end
  end
end
