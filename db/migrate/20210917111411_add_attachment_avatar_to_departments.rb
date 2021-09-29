class AddAttachmentAvatarToDepartments < ActiveRecord::Migration[6.0]
  def self.up
    change_table :departments do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :departments, :avatar
  end
end
