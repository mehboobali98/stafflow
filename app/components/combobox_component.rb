# frozen_string_literal: true

# A search-as-you-type control over a remote collection.
#
# Renders the ARIA combobox pattern: the visible input owns the role and the
# expanded state, the listbox is a sibling it points at by id, and the value
# that submits lives in a hidden field beside them.
class ComboboxComponent < BaseComponent
  # @param form [ActionView::Helpers::FormBuilder] the form the value submits with
  # @param attribute [Symbol] the attribute the hidden field is named for
  # @param url [String] JSON endpoint answering a `query` parameter
  # @param id [String] id for the visible input, and what a label points at
  # @param label_attribute [String] record attribute to show in the listbox
  def initialize(form:, attribute:, url:, id: nil, label_attribute: 'name', placeholder: nil)
    @form = form
    @attribute = attribute
    @url = url
    @id = id
    @label_attribute = label_attribute
    @placeholder = placeholder
    super()
  end

  attr_reader :form, :attribute, :url, :label_attribute, :placeholder

  def input_id
    @id || "#{form.field_id(attribute)}_search"
  end

  def listbox_id
    "#{input_id}_listbox"
  end

  def status_id
    "#{input_id}_status"
  end

  def controller_data
    {
      controller: 'combobox',
      combobox_url_value: url,
      combobox_label_attribute_value: label_attribute,
      combobox_empty_message_value: t('combobox.no_results'),
      combobox_count_message_value: t('combobox.results', count: 'COUNT'),
      action: 'click@window->combobox#dismiss'
    }
  end

  def input_data
    {
      combobox_target: 'input',
      action: 'input->combobox#search keydown->combobox#navigate'
    }
  end

  def listbox_data
    {
      combobox_target: 'listbox',
      action: 'mousedown->combobox#retainFocus click->combobox#pick'
    }
  end
end
