# frozen_string_literal: true

class ModalComponentPreview < ViewComponent::Preview
  def leave_allocation
    render_with_template(template: 'previews/modal_component/leave_allocation')
  end
end
