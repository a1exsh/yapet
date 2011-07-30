class UserSetDefaultRecordsPerPage < ActiveRecord::Migration
  def self.up
    execute("UPDATE users SET records_per_page=10 WHERE records_per_page IS NULL")

    change_column :users, :records_per_page, :integer,
      :default => 10, :null => false
  end

  def self.down
  end
end
