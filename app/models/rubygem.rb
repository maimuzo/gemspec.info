require "gemspec_a_r_extend"

class Rubygem < ActiveRecord::Base
  has_one :general_point
  # has_one :version # TODO:CHECK_ME
  has_many :versions
  has_many :what, :class_name => "What", :order => "rating_total DESC"
  has_many :strength, :class_name => "Strength", :order => "rating_total DESC"
  has_many :weakness, :class_name => "Weakness", :order => "rating_total DESC"
  
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
    
  def lastest_version
    @lastest_version ||= find_lastest_version
  end
  
  def lastest_version_reload
    find_lastest_version
  end
  
#  def gemcasts
#    comments.map {|comment| comment if "gemcast" == comment[:type]}
#  end
  
  # make LOVE chart
  def love_chart_url_with_lightblue
    # google_chart_url method and result_rating method are in the module
    google_chart_url("LOVE", result_of_rating[:ratio])
  end

    # make LOVE chart
  def love_chart_url_with_white
    # google_chart_url method and result_rating method are in the module
    google_chart_url("LOVE", result_of_rating[:ratio], "ffffff")
  end

  def count_info
    @count_info ||= {
      :whatisthis => what.count,
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

  def setup_tagging_for(tag_id)
    if @tag_id == tag_id
      return @tagging_with_tag_id ||= taggings.find_by_tag_id(tag_id)
    else
      @tag_id = tag_id
      return @tagging_with_tag_id = taggings.find_by_tag_id(tag_id)
    end
  end
  
  def tagging
    @tagging_with_tag_id
  end

private

  def find_lastest_version
    self.versions.find(:first, :order =>  "position DESC")
  end
end
