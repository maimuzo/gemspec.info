require "gemspec_a_r_extend"

class Obstacle < Comment
  acts_as_rated
  include GemspecARExtend

  validates_presence_of :user_id, :title, :comment
  attr_accessible :title, :comment
end
