class Dependency < ActiveRecord::Base
  belongs_to :version
  
  validates_presence_of :depversion, :depgem
  validates_associated :version
end
