class AddAccountOwner < ActiveRecord::Migration
  def self.up
    add_column :accounts, :owner_id, :integer

    User.all.each do |user|
      execute("UPDATE accounts SET owner_id=#{user.id} WHERE id=#{user.account.id} AND owner_id IS NULL")
    end
  end

  def self.down
    remove_column :accounts, :owner_id
  end
end
