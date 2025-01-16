# frozen_string_literal: true

module Crud
  class Create
    include ActiveModel::Model
    include NestedParamPreprocess
    include ExceptionHandling

    validate :instance_validations

    attr_reader :callbacks, :params, :instance, :klass

    def self.perform(params, callbacks, klass)
      new(params, callbacks, klass).perform
    end

    def initialize(params, callbacks, klass)
      @params = params.to_hash.deep_symbolize_keys
      @callbacks = callbacks
      @klass = klass
    end

    def perform
      prepare_nested_attributes
      @instance = load_object
      create
    end

    def create
      with_exception_handling do
        if valid?
          block_given? ? yield : instance.save!
          callbacks[:success]&.call(instance)
        else
          callbacks[:error]&.call(self)
        end
      end
    end

    private

    def load_object
      object = klass.new(params)
      yield object if block_given?
      object
    end

    def instance_validations
      errors.merge!(instance.errors) if instance.invalid?
    end
  end
end
