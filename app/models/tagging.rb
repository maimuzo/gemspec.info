class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  belongs_to :user

  acts_as_rated

  # modifyed by Maimuzo
  include GemspecARExtend

end