class AddRatingColumns < ActiveRecord::Migration
  def self.up
    Tagging.add_ratings_columns
    Rubygem.add_ratings_columns
    Abstract.add_ratings_columns
    Comment.add_ratings_columns
  end

  def self.down
    Comment.remove_ratings_columns
    Abstract.remove_ratings_columns
    Rubygem.remove_ratings_columns
    Tagging.remove_ratings_columns
  end
end
