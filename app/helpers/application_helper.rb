# frozen_string_literal: true

require 'zlib'

# Application helper
module ApplicationHelper
  FLASH_MESSAGE_COLOR = { notice: 'alert alert-success', error: 'alert alert-danger',
                          alert: 'alert alert-warning' }.freeze

  # Palette for generated initials avatars.
  AVATAR_COLORS = %w[#37517e #47b2e4 #5a6f9e #2f7d95 #6b5b95 #3d7ea6].freeze

  # The page's own title ahead of the application name, or just the
  # application name where a view has set none.
  #
  # @return [String]
  def page_title
    [content_for(:title), t('appname')].compact_blank.join(' · ')
  end

  def add_flash_bootstrap_class(message_type)
    FLASH_MESSAGE_COLOR.fetch(message_type.to_sym, 'alert alert-info')
  end

  # "Nadia Ahsan" -> "NA". Falls back to a single character for one-word names.
  def initials_for(name)
    name.to_s.split(/\s+/).reject(&:empty?).first(2).map { |word| word[0] }.join.upcase
  end

  # Deterministic avatar colour. Pass an Integer to guarantee that adjacent
  # avatars in a list differ; pass a String to derive a stable colour from it.
  def avatar_color_for(seed)
    index = seed.is_a?(Integer) ? seed : Zlib.crc32(seed.to_s)
    AVATAR_COLORS[index % AVATAR_COLORS.size]
  end
end
