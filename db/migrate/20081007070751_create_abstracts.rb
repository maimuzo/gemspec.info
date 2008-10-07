class CreateAbstracts < ActiveRecord::Migration
  def self.up
    create_table :abstracts do |t|
      t.references :user
      t.references :rubygem
      t.text :message, :default => ""
      t.string :type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :abstracts
  end
end
