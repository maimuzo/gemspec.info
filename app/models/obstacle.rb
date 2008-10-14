require "gemspec_a_r_extend"

class Obstacle < Comment
  acts_as_rated
  include GemspecARExtend

  attr_accessible :title, :comment
end
