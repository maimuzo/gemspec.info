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

ActiveRecord::Schema.define(:version => 20081006041949) do

  create_table "dependencies", :force => true do |t|
    t.integer  "version_id", :limit => 11
    t.string   "depgem"
    t.string   "depversion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dependencies", ["id"], :name => "index_dependencies_on_id"
  add_index "dependencies", ["version_id"], :name => "index_dependencies_on_version_id"

  create_table "details", :force => true do |t|
    t.integer  "version_id",     :limit => 11
    t.string   "platform"
    t.text     "executables"
    t.datetime "date"
    t.text     "summary"
    t.text     "description"
    t.text     "homepage"
    t.text     "authors"
    t.string   "email"
    t.text     "installmessage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "details", ["id"], :name => "index_details_on_id"
  add_index "details", ["version_id"], :name => "index_details_on_version_id"

  create_table "general_points", :force => true do |t|
    t.integer "rubygem_id", :limit => 11
    t.integer "point",      :limit => 11
  end

  add_index "general_points", ["id"], :name => "index_general_points_on_id"
  add_index "general_points", ["rubygem_id"], :name => "index_general_points_on_rubygem_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued",     :limit => 11
    t.integer "lifetime",   :limit => 11
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :limit => 11, :null => false
    t.string  "server_url"
    t.string  "salt",                     :null => false
  end

  create_table "rubygems", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rubygems", ["id"], :name => "index_rubygems_on_id"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.string   "sluggable_type"
    t.integer  "sluggable_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "slugs", ["name", "sluggable_type"], :name => "index_slugs_on_name_and_sluggable_type", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "specs", :force => true do |t|
    t.integer  "version_id", :limit => 11
    t.text     "yaml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.integer  "rubygem_id", :limit => 11
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gemversion"
    t.integer  "position",   :limit => 11
  end

  add_index "versions", ["id"], :name => "index_versions_on_id"
  add_index "versions", ["rubygem_id"], :name => "index_versions_on_rubygem_id"

end
