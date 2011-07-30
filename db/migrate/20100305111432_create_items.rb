class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :title, :null => false
      t.integer :account_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
