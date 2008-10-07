class TrastedOpenidProvider < ActiveRecord::Base
  validates_presence_of :endpoint_url
  validates_uniqueness_of :endpoint_url
end
