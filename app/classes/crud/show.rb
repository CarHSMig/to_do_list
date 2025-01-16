# frozen_string_literal: true

module Crud
  class Show
    include ActiveModel::Model
    attr_reader :callbacks, :instance, :find_params, :klass

    def self.perform(find_params, callbacks, klass)
      new(find_params, callbacks, klass).perform
    end

    def initialize(find_params, callbacks, klass)
      @find_params = find_params
      @callbacks = callbacks
      @klass = klass
    end

    def perform
      @instance = load_object

      if instance.present?
        show
      else
        errors.add(:instance, :not_found)
        callbacks[:not_found]&.call(self)
      end
    end

    def show
      if valid?
        callbacks[:success]&.call(instance)
      else
        callbacks[:error]&.call(self)
      end
    end

    private

    def load_object
      klass.find_by(find_params)
    end
  end
end
