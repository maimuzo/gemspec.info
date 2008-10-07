class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :user
      t.string :title, :default => ""
      t.text :comment, :default => ""
      t.column :commentable_id, :integer, :default => 0, :null => false
      t.column :commentable_type, :string, :limit => 15, :default => "", :null => false
      t.string :nico_content_key, :default => ""
      t.string :url, :default => ""
      t.string :type, :null => false
      t.string :method, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
