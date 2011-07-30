class AddUserRecordsPerPageSetting < ActiveRecord::Migration
  def self.up
    add_column :users, :records_per_page, :integer
  end

  def self.down
    remove_column :users, :records_per_page, :integer
  end
end
