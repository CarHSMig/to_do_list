# frozen_string_literal: true

module Crud
  class Destroy
    include ActiveModel::Model
    include ExceptionHandling

    attr_reader :callbacks, :instance, :params, :klass

    def self.perform(params, callbacks, klass)
      new(params, callbacks, klass).perform
    end

    def initialize(params, callbacks, klass)
      @params = params
      @callbacks = callbacks
      @klass = klass
    end

    def perform
      @instance = load_object

      if instance.present?
        destroy
      else
        errors.add(:instance, :not_found)
        callbacks[:not_found]&.call(self)
      end
    end

    def destroy
      with_exception_handling do
        if valid?
          block_given? ? yield : instance.destroy
          callbacks[:success]&.call(instance)
        else
          callbacks[:error]&.call(self)
        end
      end
    end

    private

    def load_object
      klass.find_by(params)
    end
  end
end
