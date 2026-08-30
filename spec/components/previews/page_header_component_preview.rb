# frozen_string_literal: true

class PageHeaderComponentPreview < ViewComponent::Preview
  def title_only
    render(PageHeaderComponent.new(title: 'Applied leaves'))
  end

  def with_actions_and_links
    render_with_template(template: 'previews/page_header_component/with_actions_and_links')
  end
end
