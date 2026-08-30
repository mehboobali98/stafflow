# frozen_string_literal: true

class CardComponentPreview < ViewComponent::Preview
  def plain
    render(CardComponent.new) { 'Nineteen employees, four departments.' }
  end

  def with_header
    render_with_template(template: 'previews/card_component/with_header')
  end
end
