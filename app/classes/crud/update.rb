# frozen_string_literal: true

module Crud
  class Update
    include ActiveModel::Model
    include NestedParamPreprocess
    include ExceptionHandling

    validate :instance_validations

    attr_reader :callbacks, :find_params, :params, :instance, :klass

    def self.perform(find_params, params, callbacks, klass)
      new(find_params, params, callbacks, klass).perform
    end

    def initialize(find_params, params, callbacks, klass)
      @params = params.to_hash.deep_symbolize_keys
      @find_params = find_params
      @callbacks = callbacks
      @klass = klass
    end

    def perform
      prepare_nested_attributes
      @instance = load_object

      if instance.present?
        update
      else
        errors.add(:instance, :not_found)
        callbacks[:not_found]&.call(self)
      end
    end

    def update
      with_exception_handling do
        instance.assign_attributes(params)

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
      klass.find_by(find_params)
    end

    def instance_validations
      errors.merge!(instance.errors) if instance&.invalid?
    end
  end
end
