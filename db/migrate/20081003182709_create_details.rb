class CreateDetails < ActiveRecord::Migration
  def self.up
    create_table :details do |t|
      t.references :version
      t.string :platform
      t.text :executables
      t.datetime :date
      t.text :summary
      t.text :description
      t.text :homepage
      t.text :authors
      t.string :email
      t.text :installmessage
      t.string :project_name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :details
  end
end
