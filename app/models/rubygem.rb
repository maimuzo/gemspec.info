class Rubygem < ActiveRecord::Base
  has_one :general_point
  # has_one :version # TODO:CHECK_ME
  has_many :versions
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_friendly_id :name, :use_slug => true
  acts_as_rated
  acts_as_taggable
  acts_as_commentable
  acts_as_favorite

  
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
  
  def love_rating
    if @love_rating.nil?
      total_rater = rated_count
      minus_point = total_rater - rated_total
      plus_point = total_rater - minus_point
      p_m_rate = plus_point / total_rater
      @love_rating = {
        :plus => plus_point,
        :minus => minus_point,
        :total => total_rater,
        :rate => p_m_rate
      }
    end
    @love_rating
  end
  
  # image URL for google chart
  # example
  # http://chart.apis.google.com/chart?chs=130x50&cht=gom&chf=bg,s,f8f8f8&chco=8080ff,ff8080&chl=LOVE&chd=t:0
  def love_graph_url
    rating = love_rating[:rate].to_s[0..5]
    "http://chart.apis.google.com/chart?chs=130x50&cht=gom&chf=bg,s,f8f8f8&chco=8080ff,ff8080&chl=LOVE&chd=t:" + rating
  end

private

  def find_lastest_version
    @@ar_lastest_version = self.versions.find(:first, :order =>  "position DESC")
  end
end
