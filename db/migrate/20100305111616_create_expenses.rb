class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.integer :item_id, :null => false
      t.decimal :amount, :precision => 8, :scale => 2, :null => false
      t.integer :account_id, :null => false
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :expenses
  end
end
