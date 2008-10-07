class User < ActiveRecord::Base
  acts_as_tagger
  acts_as_favorite_user
end
