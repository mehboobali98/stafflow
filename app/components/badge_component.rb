# frozen_string_literal: true

class BadgeComponent < BaseComponent
  # Leave states arrive as strings from the column. Anything not listed reads
  # as neutral rather than raising, because a badge is not the right place to
  # discover that a state machine grew a state.
  VARIANTS = {
    pending: 'text-bg-warning',
    accepted: 'text-bg-success',
    rejected: 'text-bg-danger',
    neutral: 'text-bg-secondary'
  }.freeze

  def initialize(variant: :neutral, **attributes)
    @variant = variant.to_s.to_sym
    @attributes = attributes
    super()
  end

  def call
    tag.span(content, **component_attributes(@attributes).merge(class: css_classes))
  end

  private

  def css_classes
    ['badge', 'rounded-pill', VARIANTS.fetch(@variant, VARIANTS[:neutral]),
     @attributes[:class]].compact.join(' ')
  end
end
