require "gemspec_a_r_extend"

class Unchiku < Comment
  acts_as_rated
  include GemspecARExtend

  attr_accessible :title, :comment
  
  validates_presence_of :user_id, :title
  
end
