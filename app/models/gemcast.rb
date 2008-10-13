require "gemspec_a_r_extend"

class Gemcast < Comment
  acts_as_rated
  include GemspecARExtend

  attr_accesible :title, :comment, :nico_content_key
end
