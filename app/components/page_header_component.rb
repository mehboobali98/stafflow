# frozen_string_literal: true

class PageHeaderComponent < BaseComponent
  renders_one :actions
  renders_many :links

  def initialize(title:, subtitle: nil, **attributes)
    @title = title
    @subtitle = subtitle
    @attributes = attributes
    super()
  end

  attr_reader :title, :subtitle

  def options
    component_attributes(@attributes.except(:class))
      .merge(class: ['page-header', @attributes[:class]].compact.join(' '))
  end
end
