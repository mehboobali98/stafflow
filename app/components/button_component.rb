# frozen_string_literal: true

class ButtonComponent < BaseComponent
  VARIANTS = {
    primary: 'btn-primary',
    secondary: 'btn-outline-secondary',
    success: 'btn-success',
    danger: 'btn-danger',
    ghost: 'btn-link'
  }.freeze

  SIZES = { sm: 'btn-sm', md: nil, lg: 'btn-lg' }.freeze

  def initialize(variant: :primary, size: :md, href: nil, method: nil, **attributes)
    @variant = variant.to_sym
    @size = size.to_sym
    @href = href
    @method = method
    @attributes = attributes
    super()
  end

  def call
    return link_to(content, @href, **options) if @href

    tag.button(content, **options.merge(type: @attributes.fetch(:type, 'button')))
  end

  private

  def options
    base = component_attributes(@attributes.except(:type, :class))
    base[:class] = [css_classes, @attributes[:class]].compact.join(' ')
    base[:data] = base[:data].merge(turbo_method: @method) if @method
    base
  end

  def css_classes
    ['btn', VARIANTS.fetch(@variant), SIZES.fetch(@size)].compact.join(' ')
  end
end
