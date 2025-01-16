# frozen_string_literal: true

module Deserialization
  module NestedAttributes
    def deserialize_has_many(rel, key)
      rel_params = rel['data'].map do |e|
        e.select { |k, _| %i[id attributes action].include?(k.to_sym) }
      end

      rel_params.each { |obj| _verify_object_data!(obj) }

      { "#{key}_attributes": rel_params.map { |e| e.merge(e.delete('attributes') { {} }) } }
    end

    def deserialize_has_one(rel, key)
      obj = rel['data'].select { |k, _| %i[id attributes action].include?(k.to_sym) }

      _verify_object_data!(obj)

      { "#{key}_attributes": obj.merge(obj.delete('attributes') { {} }) }
    end

    def _verify_object_data!(obj)
      raise JSONAPI::Parser::InvalidDocument, 'The "action" key must be informed' unless obj.key?('action')

      return if obj['action'].in? %w[create update delete]

      raise JSONAPI::Parser::InvalidDocument, 'The "action" values accepted are ["create", "update" or "delete"]'
    end
  end
end
