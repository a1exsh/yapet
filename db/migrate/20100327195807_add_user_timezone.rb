class AddUserTimezone < ActiveRecord::Migration
  def self.up
    add_column :users, :timezone, :string
  end

  def self.down
    drop_column :users, :timezone
  end
end
