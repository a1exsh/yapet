class CreatePasswordResetRequests < ActiveRecord::Migration
  def self.up
    create_table :password_reset_requests do |t|
      t.integer :user_id, :null => false
      t.string :code, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :password_reset_requests
  end
end
