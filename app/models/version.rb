class Version < ActiveRecord::Base
  # has_one :dependency # TODO:CHECK_ME
  has_many :dependencies
  has_one :detail
  has_one :spec
  belongs_to :rubygem
  belongs_to :source
  
  has_friendly_id :gemversion, :use_slug => true
  
  validates_presence_of :version, :gemversion
  validates_uniqueness_of :version, :scope => :rubygem_id
  validates_associated :rubygem
  
  acts_as_list :scope => :rubygem_id
  acts_as_commentable

  # test of acts_as_commentable with Single Table Inheritance for obstacles
  has_many :obstacles, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  
  before_validation :fill_gemversion
  
  # make gemversion string when before_save
  def fill_gemversion
    self.gemversion = self.rubygem.name + "_" + self.version.split(".").join("_")
  end
  
  def find_detail_and_check_empty
    detail = self.detail
    if detail.nil?
      detail = Detail.new({
        :platform => "NO DATA",
        :executables => "NO DATA",
        :date => "1900/1/1",
        :summary => "NO DATA",
        :description => "NO DATA",
        :homepage => "",
        :authors => "NO DATA",
        :email => "",
        :platform => "NO DATA",
      })
    end
    return detail
  end
end
