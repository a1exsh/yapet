class CreateTableInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :code
      t.string :email
      t.string :locale
      t.string :inviting_user_email

      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
