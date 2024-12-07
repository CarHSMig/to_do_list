# frozen_string_literal: true

module CRUDManagement
  class Create
    include ActiveModel::Model
    validate :instance_validations
    attr_reader :callbacks, :params, :instance, :klass

    def self.perform(params, callbacks, klass)
      new(params, callbacks, klass).create
    end

    def initialize(params, callbacks, klass)
      @params = params
      @callbacks = callbacks
      @klass = klass
    end

    def create
      @instance = load_object
      if valid?
        instance.save!
        callbacks[:success]&.call(instance)
      else
        merge_instance_errors
        callbacks[:error]&.call(instance)
      end
    end

    private

    def load_object
      object = klass.new(params)
      yield object if block_given?
      object
    end

    def instance_validations
      errors.merge!(@instance.errors) if instance.invalid?
    end

    def merge_instance_errors
      return if instance.nil?

      errors.attribute_names.each do |key|
        instance.errors.add(key, errors[key].join(", ").to_s) unless instance.errors.include?(key)
      end
    end
  end
end
