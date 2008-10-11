class Ratings < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_ratings_table
  end

  def self.down
    ActiveRecord::Base.drop_ratings_table
  end
end
