require "gemspec_a_r_extend"

class Rubygem < ActiveRecord::Base
  has_one :general_point
  # has_one :version # TODO:CHECK_ME
  has_many :versions
  has_many :what_is_this, :class_name => "WhatIsThis"
  has_many :strength, :class_name => "Strength"
  has_many :weakness, :class_name => "Weakness"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_friendly_id :name, :use_slug => true
  acts_as_rated
  acts_as_taggable
  acts_as_commentable
  acts_as_favorite
  
  # test of acts_as_commentable with Single Table Inheritance for gemcasts and unchikus
  has_many :gemcasts, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  has_many :unchikus, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  
  include GemspecARExtend
  
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
  
#  def gemcasts
#    comments.map {|comment| comment if "gemcast" == comment[:type]}
#  end
  
  # make LOVE chart
  def love_chart_url
    # google_chart_url method and result_rating method are in the module
    google_chart_url("LOVE", result_of_rating[:ratio])
  end

  def count_info
    @count_info ||= {
      :whatisthis => what_is_this.count,
      :strength => strength.count,
      :weakness => weakness.count,
      :gemcast => gemcasts.count,
      :unchiku => unchikus.count,
      :obstacle => lastest_version.obstacles.count
    }
  end

  def tag_string
    if @tag_array.nil?
      @tag_array = []
      tags.each {|tag| @tag_array << tag.name}
    end
    @tag_array.join(", ")
  end


private

  def find_lastest_version
    @@ar_lastest_version = self.versions.find(:first, :order =>  "position DESC")
  end
end
