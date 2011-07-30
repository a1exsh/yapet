class AddExpenseDate < ActiveRecord::Migration
  def self.up
    add_column :expenses, :date, :timestamp
    Expense.reset_column_information
    ActiveRecord::Base.record_timestamps = false
    Expense.update_all("date = created_at")
    ActiveRecord::Base.record_timestamps = true
  end

  def self.down
    remove_column :expenses, :date
  end
end
