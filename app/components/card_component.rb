# frozen_string_literal: true

class CardComponent < BaseComponent
  renders_one :header
  renders_one :footer

  def initialize(**attributes)
    @attributes = attributes
    super()
  end

  def options
    component_attributes(@attributes.except(:class))
      .merge(class: ['card', @attributes[:class]].compact.join(' '))
  end
end
