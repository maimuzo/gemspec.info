class CreateCloneSites < ActiveRecord::Migration
  def self.up
    create_table :clone_sites do |t|
      t.string :name
      t.string :domain
      t.string :country

      t.timestamps
    end
  end

  def self.down
    drop_table :clone_sites
  end
end
