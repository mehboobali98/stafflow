# frozen_string_literal: true

# Wraps the shell rather than the data. Eighteen views build a table by hand and
# every one of them has a different row; standardising the chrome is what they
# share, and forcing a column API onto them would be a rewrite rather than a
# component.
class TableComponent < BaseComponent
  renders_one :head
  renders_one :body

  def initialize(**attributes)
    @attributes = attributes
    super()
  end

  def options
    component_attributes(@attributes.except(:class))
      .merge(class: ['table', 'align-middle', @attributes[:class]].compact.join(' '))
  end
end
