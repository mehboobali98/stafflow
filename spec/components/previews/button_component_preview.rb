# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  def variants
    render_with_template(template: 'previews/button_component/variants')
  end

  def sizes
    render_with_template(template: 'previews/button_component/sizes')
  end

  # @param label text
  # @param variant select { choices: [primary, secondary, success, danger, ghost] }
  # @param size select { choices: [sm, md, lg] }
  def playground(label: 'Apply for leave', variant: :primary, size: :md)
    render(ButtonComponent.new(variant: variant, size: size)) { label }
  end
end
