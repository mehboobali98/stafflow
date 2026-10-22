# frozen_string_literal: true

class IconComponentPreview < ViewComponent::Preview
  def sizes
    render_with_template(template: 'previews/icon_component/sizes')
  end

  def every_icon
    render_with_template(template: 'previews/icon_component/every_icon')
  end
end
