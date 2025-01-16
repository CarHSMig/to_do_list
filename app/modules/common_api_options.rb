# frozen_string_literal: true

module CommonApiOptions
  def default_create_callbacks(serializable_classes: {}, expose_values: {})
    {
      success: success_callback_default(status: :created, serializable_classes:, expose_values:),
      error: error_callback_default
    }
  end

  def default_index_callbacks(serializable_classes: {}, expose_values: {})
    { success: success_callback_default(serializable_classes:, expose_values:) }
  end

  def index_with_pagination_callback(serializable_classes: {}, expose_values: {})
    {
      success: index_callback_with_page_links(serializable_classes:, expose_values:),
      error: error_callback_default
    }
  end

  def default_callbacks(serializable_classes: {}, expose_values: {})
    {
      success: success_callback_default(serializable_classes:, expose_values:),
      error: error_callback_default,
      not_found: not_found_callback_default
    }
  end


  alias default_show_callbacks default_callbacks
  alias default_update_callbacks default_callbacks
  alias default_destroy_callbacks default_callbacks

  private

  def success_callback_default(status: :ok, serializable_classes: {}, expose_values: {})
    lambda do |caller|
      render jsonapi: caller,
             status:,
             fields: fields_options,
             include: include_options,
             class: jsonapi_class.merge(serializable_classes),
             expose: expose_values
    end
  end

  def index_callback_with_page_links(serializable_classes: {}, expose_values: {})
    lambda do |caller, meta_extra_options: {}|
      render jsonapi: caller,
             status: :ok,
             fields: fields_options,
             include: include_options,
             class: jsonapi_class.merge(serializable_classes),
             expose: expose_values,
             links: pagination_links(caller),
             meta: meta(caller).merge(meta_extra_options)
    end
  end

  def error_callback_default
    lambda do |caller|
      render jsonapi_errors: caller.errors, status: :unprocessable_entity
    end
  end

  def not_found_callback_default
    lambda do |caller|
      render jsonapi_errors: caller.errors, status: :not_found
    end
  end

  def include_options
    params.slice(:include).as_json.deep_symbolize_keys[:include]
  end

  def fields_options
    options = params.permit(fields: {}).as_json.deep_symbolize_keys[:fields]
    return {} if options.blank?

    options.transform_values { |v| v.split(',').collect { |e| e.strip.to_sym } }
  end

  def search_params
    params.permit(q: {})
  end

  def sort_options
    sort_params = params.permit(:sort)
    sort_params.transform_keys { |_k| :s }
  end

  def ransack_options
    (search_params[:q] || {}).merge(sort_options)
  end

  def paginate_params
    params.permit(:page, :per_page)
  end
end
