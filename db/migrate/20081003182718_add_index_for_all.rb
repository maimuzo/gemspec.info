class AddIndexForAll < ActiveRecord::Migration
  def self.up
    add_index :rubygems, :id
    add_index :versions, :id
    add_index :versions, :rubygem_id
    add_index :details, :id
    add_index :details, :version_id
    add_index :dependencies, :id
    add_index :dependencies, :version_id
    add_index :general_points, :id
    add_index :general_points, :rubygem_id
  end

  def self.down
    remove_index :rubygems, :id
    remove_index :versions, :id
    remove_index :versions, :rubygem_id
    remove_index :details, :id
    remove_index :details, :version_id
    remove_index :dependencies, :id
    remove_index :dependencies, :version_id
    remove_index :general_points, :id
    remove_index :general_points, :rubygem_id
  end
end
