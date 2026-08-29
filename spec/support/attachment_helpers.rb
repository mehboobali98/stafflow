# frozen_string_literal: true

# Uploads for the Active Storage specs. The oversized file is a real PNG with
# padding after it: the size validator has to see something over the limit, and
# the content type validator has to still recognise it, or the example would
# pass for the wrong reason.
module AttachmentHelpers
  def upload(name, type)
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files', name), type)
  end

  def oversized_png
    tmp = Tempfile.new(['big', '.png'], binmode: true)
    tmp.write(Rails.root.join('spec/fixtures/files/avatar.png').binread)
    tmp.write("\0" * 4.megabytes)
    tmp.rewind
    Rack::Test::UploadedFile.new(tmp.path, 'image/png')
  end
end
