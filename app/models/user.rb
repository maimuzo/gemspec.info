require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :what_is_this
  has_many :strength
  has_many :weakness
  
  acts_as_tagger
  acts_as_favorite_user
  # favorite extend by hand
  has_many :favorite_gems, :through => :favorites, :source => :favorable, :source_type => 'Rubygem'
  
  validates_presence_of :nickname, :claimed_url
  validates_uniqueness_of :nickname, :claimed_url, :user_key
  attr_protected :claimed_url, :created_at, :updated_at, :salt, :user_key
  before_save :generate_user_key

protected
  
  # Encrypts some data with the salt.
  def generate_user_key
    self.salt = make_activation_code
    self.user_key = Digest::SHA1.hexdigest("--#{self.salt}--#{self.claimed_url}--")
  end

  def make_activation_code
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

end
