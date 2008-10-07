# Defines named favorites for users that may be applied to objects in a polymorphic fashion.
class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorable, :polymorphic => true

  acts_as_rated

end
