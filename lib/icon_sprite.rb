# frozen_string_literal: true

# Regenerates app/views/shared/_icon_sprite.html.erb from bootstrap-icons.
# The sprite is committed, so this is only needed when the icon set changes;
# bootstrap-icons is a devDependency for that reason and ships nothing.
#
#   docker compose run --rm web ruby lib/icon_sprite.rb

require 'fileutils'

ICONS = %w[
  trash list eye building person-gear unlock list-task box-arrow-right receipt
  gear-wide-connected chevron-right chevron-left graph-up grid-3x3 person
  calendar-plus calendar-event bell people-fill
  buildings shield-lock calendar-check cash-stack
].freeze

out = +<<~HEADER
  <%# Generated from bootstrap-icons 1.13.1 (MIT) by lib/icon_sprite.rb.
      Inlined rather than linked so the icons need no font, no request and no
      gem, and take their colour from the text around them. %>
  <svg xmlns="http://www.w3.org/2000/svg" class="icon-sprite" aria-hidden="true">
HEADER

ICONS.each do |name|
  svg = File.read("node_modules/bootstrap-icons/icons/#{name}.svg")
  viewbox = svg[/viewBox="([^"]+)"/, 1]
  inner = svg[%r{<svg[^>]*>(.*)</svg>}m, 1].strip
  out << %(  <symbol id="icon-#{name}" viewBox="#{viewbox}">#{inner}</symbol>\n)
end

out << "</svg>\n"
FileUtils.mkdir_p('app/views/shared')
File.write('app/views/shared/_icon_sprite.html.erb', out)
puts "wrote #{ICONS.size} symbols, #{out.bytesize} bytes"
