# frozen_string_literal: true

class FormFieldComponentPreview < ViewComponent::Preview
  def text
    render_with_template(template: 'previews/form_field_component/text')
  end

  def with_error
    render_with_template(template: 'previews/form_field_component/with_error')
  end
end
