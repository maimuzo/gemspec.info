class AddColumnsToVersions < ActiveRecord::Migration
  def self.up
    add_column :versions, :gemfile, :string
    add_column :versions, :rdoc_path, :string
    add_column :versions, :diagram_path, :string
    add_column :versions, :last_gen_rdoc, :datetime
    add_column :versions, :source_id, :integer # for github, not impliment yet
    add_index :versions, :source_id
  end

  def self.down
    remove_index :versions, :source_id
    remove_column :versions, :source_id
    remove_column :versions, :diagram_path
    remove_column :versions, :rdoc_path
    remove_column :versions, :gemfile
  end
end
