# frozen_string_literal: true

module CRUDManagement
  class Update
    include ActiveModel::Model

    validate :instance_validations
    validates :instance, presence: { message: :not_found }

    attr_reader :callbacks, :find_params, :params, :instance, :klass

    def self.perform(find_params, params, callbacks, klass)
      new(find_params, params, callbacks, klass).update
    end

    def initialize(find_params, params, callbacks, klass)
      @params = params
      @find_params = find_params
      @callbacks = callbacks
      @klass = klass
      @instance = load_object
    end

    def update
      instance&.assign_attributes(params)
      if valid?
        instance.save
        callbacks[:success]&.call(instance)
      else
        merge_instance_errors
        callbacks[:error]&.call(instance || self)
      end
    end

    private

    def load_object
      klass.find_by(find_params)
    end

    def instance_validations
      errors.merge!(instance.errors) if instance&.invalid?
    end

    def merge_instance_errors
      return if instance.nil?

      errors.attribute_names.each do |key|
        instance.errors.add(key, errors[key].join(", ").to_s) unless instance.errors.include?(key)
      end
    end
  end
end
