# frozen_string_literal: true

class EmptyStateComponentPreview < ViewComponent::Preview
  def default
    render(EmptyStateComponent.new(title: 'No leave requests yet',
                                   description: 'Requests appear here once someone applies.'))
  end
end
