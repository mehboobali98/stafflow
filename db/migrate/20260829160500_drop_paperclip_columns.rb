# frozen_string_literal: true

# Paperclip kept its metadata in four columns per attachment. Active Storage
# keeps it in active_storage_blobs, so these are dead once the models switch.
#
# A deployment holding real uploads has to copy them into Active Storage before
# this runs - the file names live here and nowhere else, so dropping first
# loses the only record of what was attached. This repository has none: the
# uploads were purged from git history in phase 0 and the seeds create none.
class DropPaperclipColumns < ActiveRecord::Migration[7.1]
  def up
    remove_columns :departments, :avatar_file_name, :avatar_content_type,
                   :avatar_file_size, :avatar_updated_at
    remove_columns :users, :image_file_name, :image_content_type,
                   :image_file_size, :image_updated_at
  end

  def down
    add_column :departments, :avatar_file_name, :string
    add_column :departments, :avatar_content_type, :string
    add_column :departments, :avatar_file_size, :integer
    add_column :departments, :avatar_updated_at, :datetime

    add_column :users, :image_file_name, :string
    add_column :users, :image_content_type, :string
    add_column :users, :image_file_size, :integer
    add_column :users, :image_updated_at, :datetime
  end
end
