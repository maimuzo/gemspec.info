class CreateTrastedOpenidProviders < ActiveRecord::Migration
  def self.up
    create_table :trasted_openid_providers do |t|
      t.string :endpoint_url

      t.timestamps
    end
  end

  def self.down
    drop_table :trasted_openid_providers
  end
end
