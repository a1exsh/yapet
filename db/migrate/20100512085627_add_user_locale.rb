class AddUserLocale < ActiveRecord::Migration
  def self.up
    add_column :users, :locale, :string

    # TODO: or would :default => 'en' work?
    execute("UPDATE users SET locale='en' WHERE locale IS NULL")
  end

  def self.down
    remove_column :users, :locale
  end
end
