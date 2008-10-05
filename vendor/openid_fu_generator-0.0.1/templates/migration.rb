class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>, :force => true do |t|
      t.string :nickname
      t.string :email
      t.string :claimed_id
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.string :open_id_claimed_identifier
      <% if options[:include_activation] %>
      t.string :activation_code, :limit => 40
      t.datetime :activated_at
      <% end %>
      <% unless options[:exclude_personal_identity] %>
      # Common properties among SREG and AX
      t.string :fullname
      t.string :birth_date
      t.integer :gender, :limit => 1
      t.string :postcode
      t.string :country
      t.string :language
      t.string :timezone
      <% end %>
      t.timestamps
    end

    create_table :open_id_associations, :force => true do |t|
      t.binary :server_url
      t.string :handle
      t.binary :secret
      t.integer :issued
      t.integer :lifetime
      t.string :assoc_type

      t.timestamps
    end

    create_table :open_id_nonces, :force => true do |t|
      t.string :server_url, :null => false
      t.integer :timestamp, :null => false
      t.string :salt, :null => false

      t.timestamps
    end

  end

  def self.down
    drop_table :<%= table_name %>
    drop_table :open_id_associations
    drop_table :open_id_nonces
  end
end
