# frozen_string_literal: true

class TableComponentPreview < ViewComponent::Preview
  def leave_queue
    render_with_template(template: 'previews/table_component/leave_queue')
  end
end
