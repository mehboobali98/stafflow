# frozen_string_literal: true

require 'vips'

# Uploads for the Active Storage specs. `spoofed.png` is a text file under a PNG
# name - replacing it with a real image would leave the spoofing example
# asserting nothing.
module AttachmentHelpers
  # Random pixels, because PNG compresses a large flat image back under the
  # limit, and 1200 square of them encodes to roughly 4 MB.
  OVERSIZED_EDGE = 1200

  def upload(name, type)
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files', name), type)
  end

  # A real image rather than a small one with bytes appended, so nothing here
  # rests on a decoder tolerating trailing junk - the spoofing check on both
  # attachments reads these bytes too.
  def oversized_png
    pixels = Random.bytes(OVERSIZED_EDGE * OVERSIZED_EDGE * 3)
    png = Vips::Image.new_from_memory(pixels, OVERSIZED_EDGE, OVERSIZED_EDGE, 3, :uchar).pngsave_buffer

    tmp = Tempfile.new(['big', '.png'], binmode: true)
    tmp.write(png)
    tmp.rewind
    Rack::Test::UploadedFile.new(tmp.path, 'image/png')
  end
end
