class Version < ActiveRecord::Base
  # has_one :dependency # TODO:CHECK_ME
  has_many :dependencies
  has_one :detail
  has_one :spec
  belongs_to :rubygem
end
