class Rubygem < ActiveRecord::Base
  has_one :general_point
  # has_one :version # TODO:CHECK_ME
  has_many :versions
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
