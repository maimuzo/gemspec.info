class AddColumnsToVersions < ActiveRecord::Migration
  def self.up
    add_column :versions, :gemfile, :string
    add_column :versions, :rdoc_path, :string
    add_column :versions, :diagram_path, :string
  end

  def self.down
    remove_column :versions, :diagram_path
    remove_column :versions, :rdoc_path
    remove_column :versions, :gemfile
  end
end
