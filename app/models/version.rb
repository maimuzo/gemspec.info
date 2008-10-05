class Version < ActiveRecord::Base
  # has_one :dependency # TODO:CHECK_ME
  has_many :dependencies
  has_one :detail
  has_one :spec
  belongs_to :rubygem
  
  has_friendly_id :gemversion, :use_slug => true
  
  validates_presence_of :version, :gemversion
  validates_uniqueness_of :version, :scope => :rubygem_id
  validates_associated :rubygem
  
  acts_as_list :scope => :rubygem_id
  
  def before_validation
    fill_gemversion
  end
  
  # make gemversion string when before_save
  def fill_gemversion
    self.gemversion = self.rubygem.name + "_" + self.version.split(".").join("_")
  end
    
end
