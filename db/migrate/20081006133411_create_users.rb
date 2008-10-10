class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :nickname
      t.string :email
      t.string :claimed_url
      t.string :fullname
      t.date :birth_date
      t.integer :gender
      t.string :postcode
      t.string :country
      t.string :language
      t.string :timezone
      t.string :salt
      t.string :user_key

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
