class AddSequenceNumToUserbenefits < ActiveRecord::Migration[6.0]
  def self.up
    add_column :user_benefits, :sequence_num, :integer, null: false
    update_sequence_num_values
    add_index :user_benefits, %i[sequence_num company_id], unique: true
  end

  def self.down
    remove_index  :user_benefits, column: %i[sequence_num company_id]
    remove_column :user_benefits, :sequence_num
  end

  def self.update_sequence_num_values
    Company.all.each do |parent|
      cntr = 1
      parent.user_benefits.reorder('id').all.each do |nested|
        nested.sequence_num = cntr
        cntr += 1
        nested.save(validate: false)
      end
    end
  end
end
