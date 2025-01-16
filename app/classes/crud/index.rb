# frozen_string_literal: true

module Crud
  class Index
    include ActiveModel::Model
    attr_reader :callbacks, :page, :per_page, :ransack_params, :list, :klass, :params

    def self.perform(params, callbacks, klass)
      new(params, callbacks, klass).index
    end

    def initialize(params, callbacks, klass)
      @params = params
      @page = params.delete(:page) || 1
      @per_page = params.delete(:per_page)
      @ransack_params = params.delete(:ransack_params) || {}
      @callbacks = callbacks
      @klass = klass
    end

    def index
      @list = load_object
      @per_page = per_page == 'all' ? list.count : per_page.to_i
      callbacks[:success]&.call(list.page(page).per(valid_per_page))
    end

    def load_object
      klass.where(params).ransack(@ransack_params).result
    end

    def valid_per_page
      per_page.eql?(0) ? nil : per_page
    end
  end
end
