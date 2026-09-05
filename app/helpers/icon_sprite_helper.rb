# frozen_string_literal: true

# The names the sprite defines, read from the sprite itself rather than kept in
# a second list that could drift from it.
module IconSpriteHelper
  SPRITE = Rails.root.join('app/views/shared/_icon_sprite.html.erb')

  def self.icon_names
    SPRITE.read.scan(/<symbol id="icon-([^"]+)"/).flatten
  end
end
