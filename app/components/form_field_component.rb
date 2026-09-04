# frozen_string_literal: true

# Label, control and error as one unit.
#
# The label is built from the attribute rather than from its text, which is the
# whole point: 34 labels across 12 views called `form.label t('forms.labels.x')`,
# and Rails read that translated string as the attribute name. Each one pointed
# `for` at an id that does not exist - `user_Email` against `user_email` - so
# the label was associated with nothing.
class FormFieldComponent < BaseComponent
  SELECT_CONTROLS = %i[select collection_select].freeze
  CHECK_CONTROLS  = %i[check_box].freeze

  def initialize(form:, attribute:, label: nil, as: :text_field, hint: nil, **input_options)
    @form = form
    @attribute = attribute
    @label = label
    @as = as.to_sym
    @hint = hint
    @input_options = input_options
    super()
  end

  attr_reader :form, :attribute, :hint

  # Falls back to what `form.label` would have produced on its own. A form
  # built with `scope:` rather than `model:` has no object at all - `form.object`
  # is `false` - so there is nothing to ask for a translation.
  def label
    @label || translated_label || attribute.to_s.humanize
  end

  # An explicit id on the control is the id the label has to point at. Getting
  # this wrong is the defect this component exists to fix, one layer up.
  def label_for
    @input_options[:id] || form.field_id(attribute)
  end

  def control
    return content if content?

    form.public_send(@as, attribute, **@input_options.merge(class: control_class))
  end

  def control_class
    base = if SELECT_CONTROLS.include?(@as)
             'form-select'
           elsif CHECK_CONTROLS.include?(@as)
             'form-check-input'
           else
             'form-control'
           end
    [base, ('is-invalid' if errors.any?), @input_options[:class]].compact.join(' ')
  end

  def errors
    object = form.object
    return [] unless object.respond_to?(:errors)

    object.errors.full_messages_for(attribute)
  end

  def describedby
    return nil if hint.blank? && errors.empty?

    [("#{field_id}_hint" if hint.present?), ("#{field_id}_error" if errors.any?)].compact.join(' ')
  end

  def field_id
    label_for
  end

  private

  def translated_label
    klass = form.object.class
    klass.human_attribute_name(attribute) if klass.respond_to?(:human_attribute_name)
  end
end
