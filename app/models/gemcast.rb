require "gemspec_a_r_extend"

class Gemcast < Comment
  acts_as_rated
  include GemspecARExtend

  validates_presence_of :user_id, :title, :nico_content_key
  validates_uniqueness_of :nico_content_key
  attr_accessible :title, :comment, :nico_content_key
  
end
