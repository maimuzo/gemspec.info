class CreateRubygems < ActiveRecord::Migration
  def self.up
    create_table :rubygems do |t|
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :rubygems
  end
end
