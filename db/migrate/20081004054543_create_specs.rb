class CreateSpecs < ActiveRecord::Migration
  def self.up
    create_table :specs do |t|
      t.references :version
      t.text :yaml

      t.timestamps
    end
  end

  def self.down
    drop_table :specs
  end
end
