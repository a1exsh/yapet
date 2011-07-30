class AddItemCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :title, :null => false
      t.integer :parent_id
      t.integer :account_id, :null => false

      t.timestamps
    end

    add_column :items, :category_id, :integer
  end

  def self.down
    remove_column :items, :category_id
    drop_table :categories
  end
end
