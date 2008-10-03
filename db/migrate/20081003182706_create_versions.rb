class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.references :rubygem
      t.string :version
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :versions
  end
end
