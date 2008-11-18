class AddIndexForAlphaVersion < ActiveRecord::Migration
  def self.up
#    add_index :rubygems, :id
    add_index :abstracts, :user_id
    add_index :abstracts, :rubygem_id
    add_index :abstracts, :type
    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
    add_index :comments, :type
    add_index :comments, :tried_times
    add_index :comments, :updated_at
    add_index :favorites, :user_id
    add_index :favorites, [:favorable_id, :favorable_type]
    add_index :specs, :version_id
    add_index :users, :claimed_url
    add_index :users, :user_key    
    add_index :versions, :position    
    add_index :rubygems, :name
    add_index :versions, :version
  end

  def self.down
#    remove_index :rubygems, :id
    remove_index :versions, :position    
    remove_index :users, :user_key    
    remove_index :users, :claimed_url
    remove_index :specs, :version_id
    remove_index :favorites, [:favorable_id, :favorable_type]
    remove_index :favorites, :user_id
    remove_index :comments, :updated_at
    remove_index :comments, :tried_times
    remove_index :comments, :type
    remove_index :comments, [:commentable_id, :commentable_type]
    remove_index :comments, :user_id
    remove_index :abstracts, :type
    remove_index :abstracts, :rubygem_id
    remove_index :abstracts, :user_id
    remove_index :versions, :version    
    remove_index :rubygems, :name    
  end
end
