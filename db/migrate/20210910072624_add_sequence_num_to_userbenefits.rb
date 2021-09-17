class AddSequenceNumToUsersBenefits < ActiveRecord::Migration[6.0]
  def self.up
    add_column :users_benefits, :sequence_num, :integer, null: false
    update_sequence_num_values
    add_index :users_benefits, %i[sequence_num company_id], unique: true
  end

  def self.down
    remove_index  :users_benefits, column: %i[company_id sequence_num]
    remove_column :users_benefits, :sequence_num
  end

  def self.update_sequence_num_values
    Company.all.each do |parent|
      cntr = 1
      parent.users_benefits.reorder('id').all.each do |nested|
        nested.sequence_num = cntr
        cntr += 1
        nested.save(validate: false)
      end
    end
  end
end
