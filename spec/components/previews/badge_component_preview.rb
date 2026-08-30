# frozen_string_literal: true

class BadgeComponentPreview < ViewComponent::Preview
  def states
    render_with_template(template: 'previews/badge_component/states')
  end
end
