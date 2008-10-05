class Rubygem < ActiveRecord::Base
  has_one :general_point
  # has_one :version # TODO:CHECK_ME
  has_many :versions
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_friendly_id :name, :use_slug => true
  
  # ar holder
  @@ar_lastest_version = nil
  
  def lastest_version
    if @@ar_lastest_version.nil?
      find_lastest_version
    else
      @@ar_lastest_version
    end
  end
  
  def lastest_version_reload
    find_lastest_version
  end

private

  def find_lastest_version
    @@ar_lastest_version = self.versions.find(:first, :order =>  "position DESC")
  end
end
