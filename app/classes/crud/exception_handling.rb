# frozen_string_literal: true

module Crud
  module ExceptionHandling
    def with_exception_handling
      yield
    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.full_message}")
      errors.add(:base, I18n.t('api.errors.unexpected_error', error: e.message))
      callbacks[:error]&.call(self)
    end
  end
end
