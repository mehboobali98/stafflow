class AddSequenceNumToBenefits < ActiveRecord::Migration[6.0]
  def self.up
    add_column :benefits, :sequence_num, :integer, null: false
    update_sequence_num_values
    add_index :benefits, %i[company_id sequence_num], unique: true
  end

  def self.down
    remove_index :benefits, column: %i[company_id sequence_num]
    remove_column :benefits, :sequence_num
  end

  def self.update_sequence_num_values
    Company.all.each do |parent|
      cntr = 1
      parent.benefits.order('created_at').all.each do |nested|
        nested.sequence_num = cntr
        cntr += 1
        nested.save
      end
    end
  end
end
