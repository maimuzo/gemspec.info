class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  belongs_to :user

  acts_as_rated

  # modifyed by Maimuzo
  def result_of_rating
    total_rater = rated_count
    diff = (total_rater - rated_total) / 2
    plus_point = rated_count - diff
    minus_point = rated_count - plus_point
    begin
      ratio = (((total_rater + rated_total) / (total_rater * 2)) * 100).to_s
      ratio = ratio[0..2] if ratio.length > 2
    rescue ZeroDivisionError
      ratio = "50"
    end
    {
      :plus => plus_point.to_s,
      :minus => minus_point.to_s,
      :total => total_rater.to_s,
      :ratio => ratio
    }
  end

end