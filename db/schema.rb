# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101029194053) do

  create_table "accounts", :force => true do |t|
    t.date     "paid_till"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.boolean  "sandbox",    :default => false
  end

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "title",      :null => false
    t.integer  "parent_id"
    t.integer  "account_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expenses", :force => true do |t|
    t.integer  "item_id",                                  :null => false
    t.decimal  "amount",     :precision => 8, :scale => 2, :null => false
    t.integer  "account_id",                               :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date"
  end

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.string   "email"
    t.string   "locale"
    t.string   "inviting_user_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "title",       :null => false
    t.integer  "account_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  create_table "password_reset_requests", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "code",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "account_id",                         :null => false
    t.string   "email",                              :null => false
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone"
    t.integer  "records_per_page", :default => 10,   :null => false
    t.string   "locale"
    t.boolean  "show_guide",       :default => true
    t.integer  "invites_left",     :default => 15
  end

end
