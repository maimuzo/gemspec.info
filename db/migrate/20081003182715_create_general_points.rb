class CreateGeneralPoints < ActiveRecord::Migration
  def self.up
    create_table :general_points do |t|
      t.references :rubygem
      t.integer :point
    end
  end

  def self.down
    drop_table :general_points
  end
end
