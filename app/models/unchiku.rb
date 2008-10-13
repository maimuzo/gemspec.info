require "gemspec_a_r_extend"

class Unchiku < Comment
  acts_as_rated
  include GemspecARExtend

  attr_accesible :title, :comment
end
