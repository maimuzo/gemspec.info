class CreateDependencies < ActiveRecord::Migration
  def self.up
    create_table :dependencies do |t|
      t.references :version
      t.string :depgem
      t.string :depversion
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :dependencies
  end
end
