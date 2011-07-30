class AddUserShowGuide < ActiveRecord::Migration
  def self.up
    add_column :users, :show_guide, :boolean, :default => true

    # turn off guide for existing users
    User.reset_column_information
    User.update_all({ :show_guide => false })
  end

  def self.down
    remove_column :users, :show_guide
  end
end
