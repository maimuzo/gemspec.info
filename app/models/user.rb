class User < ActiveRecord::Base
  has_many :what_is_this
  has_many :strength
  has_many :weakness
  
  acts_as_tagger
  acts_as_favorite_user
end
