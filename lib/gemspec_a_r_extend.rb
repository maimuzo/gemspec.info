module GemspecARExtend

  # calculate rating
  # rated_count : 5
  # rated_total : 3
  # => 4/1 5 ratio:
  # rated_count : 3
  # rated_total : -1
  # => 1/2 3
  # rated_count : 3
  # rated_total : 1
  # => 2/1 3
  # rated_count : 1
  # rated_total : -1
  # => 0/1 1
  # rated_count : 1
  # rated_total : 1
  # => 1/0 1
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
    logger.debug "rated_count : " + rated_count.inspect
    logger.debug "rated_total : " + rated_total.inspect
    logger.debug "ratio : " + ratio.inspect
    {
      :plus => plus_point.to_s,
      :minus => minus_point.to_s,
      :total => total_rater.to_s,
      :ratio => ratio
    }
  end
  
  # make USEFUL chart
  def useful_chart_url
    google_chart_url("USEFUL", result_of_rating[:ratio])
  end

  # formated string
  def last_update_string
    updated_at.strftime("%Y/%m/%d %H:%M:%S")
  end
  
  
  # image URL for google chart
  # example
  # http://chart.apis.google.com/chart?chs=180x100&cht=gom&chf=bg,s,f8f8f8&chco=8080ff,ff8080&chl=LOVE&chd=t:0
  def google_chart_url(label, ratio, bgcolor = "f8f8f8")
    "http://chart.apis.google.com/chart?chs=80x50&cht=gom&chf=bg,s,#{bgcolor}&chco=8080ff,ff8080&chd=t:#{ratio}"
  end
    
end
