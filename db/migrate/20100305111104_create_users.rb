class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :account_id, :null => false
      t.string :email, :null => false
      t.string :hashed_password
      t.string :salt

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
