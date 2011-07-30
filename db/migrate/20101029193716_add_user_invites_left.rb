class AddUserInvitesLeft < ActiveRecord::Migration
  def self.up
    add_column :users, :invites_left, :integer, :default => 15

    # not all DBs use default for existing records
    User.reset_column_information
    User.update_all({ :invites_left => 15 })
  end

  def self.down
    remove_column :users, :invites_left
  end
end
