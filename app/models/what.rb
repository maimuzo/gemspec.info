class What < Abstract
  belongs_to :user
  belongs_to :rubygem
  acts_as_rated
end
