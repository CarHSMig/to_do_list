# frozen_string_literal: true

# Process and prepare nested attributes to be save trough accepts_nested_attributes_for on a main Model.
module NestedParamPreprocess
  private

  # rubocop:disable Metrics/MethodLength
  def prepare_nested_attributes
    return unless klass.present? && klass.nested_attributes_options?

    nested_keys = klass.nested_attributes_options.keys.map { |nested_attr| :"#{nested_attr}_attributes" }

    nested_keys.each do |nested|
      next if @params[nested].blank?

      if @params[nested].is_a?(Array)
        prepare_nested_array(@params[nested])
      else
        prepare_nested(@params[nested])
      end

      @params[nested]
    end
  end
  # rubocop:enable Metrics/MethodLength

  def prepare_nested_array(params)
    params.each do |object|
      prepare_nested(object)
    end
  end

  def prepare_nested(object)
    case object[:action]&.to_sym
    when :create
      object.except!(:id)
    when :delete
      object[:_destroy] = '1'
    end

    object.except!(:action)
  end
end
