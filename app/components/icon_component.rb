# frozen_string_literal: true

# An inline SVG icon, drawn from the sprite the layout renders once.
#
# This replaces font-awesome, which cost a gem, a webfont on every page and the
# font-load race that screenshots had to wait out. A `<use>` reference costs a
# line of markup and takes its colour from the text around it.
#
# Decorative by default: an icon beside a label adds nothing for a screen
# reader and is hidden from it. Pass `label:` when the icon is the only thing
# in its control, which is what the row action links do.
class IconComponent < BaseComponent
  SIZES = { sm: 'icon--sm', md: nil, lg: 'icon--lg' }.freeze

  def initialize(name, label: nil, size: :md, **attributes)
    @name = name.to_s
    @label = label
    @size = size.to_sym
    @attributes = attributes
    super()
  end

  attr_reader :label

  def call
    tag.svg(tag.use(nil, href: "#icon-#{@name}"), **options)
  end

  private

  def options
    base = component_attributes(@attributes.except(:class))
    base[:class] = ['icon', SIZES.fetch(@size), @attributes[:class]].compact.join(' ')
    base[:fill] = 'currentColor'
    if label.present?
      base[:role] = 'img'
      base['aria-label'] = label
    else
      base['aria-hidden'] = 'true'
    end
    base
  end
end
