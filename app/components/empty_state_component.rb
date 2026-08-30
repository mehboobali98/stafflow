# frozen_string_literal: true

class EmptyStateComponent < BaseComponent
  def initialize(title:, description: nil, **attributes)
    @title = title
    @description = description
    @attributes = attributes
    super()
  end

  attr_reader :title, :description

  def options
    component_attributes(@attributes.except(:class))
      .merge(class: ['text-center', 'text-secondary', 'py-5', @attributes[:class]].compact.join(' '))
  end
end
