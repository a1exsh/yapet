class AddAccountSandbox < ActiveRecord::Migration
  def self.up
    add_column :accounts, :sandbox, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :sandbox
  end
end
