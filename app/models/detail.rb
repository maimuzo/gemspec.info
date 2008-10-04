class Detail < ActiveRecord::Base
  belongs_to :version
  validates_associated :version
end
