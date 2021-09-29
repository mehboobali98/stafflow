class AddSequenceNumToPayrolls < ActiveRecord::Migration[6.0]
  def self.up
    add_column :payrolls, :sequence_num, :integer, null: false
    update_sequence_num_values
    add_index :payrolls, %i[company_id sequence_num], unique: true
  end

  def self.down
    remove_index :payrolls, column: %i[sequence_num company_id]
    remove_column :payrolls, :sequence_num
  end

  def self.update_sequence_num_values
    Company.all.each do |parent|
      cntr = 1
      parent.payrolls.order('created_at').all.each do |nested|
        nested.sequence_num = cntr
        cntr += 1
        nested.save
      end
    end
  end
end
