class CreateSystemStates < ActiveRecord::Migration
  def self.up
    create_table :system_states do |t|
      t.integer :total_gem
      t.integer :total_version
      t.integer :spec_counter
      t.integer :rdoc_counter
      t.integer :diagram_counter
      t.string :help_gems

      t.timestamps
    end
  end

  def self.down
    drop_table :system_states
  end
end
