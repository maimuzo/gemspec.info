module GemspecARExtend

  # calculate rating
  def result_of_rating
    total_rater = rated_count
    minus_point = total_rater - rated_total
    plus_point = total_rater - minus_point
    begin
      ratio = (plus_point / total_rater).to_s
      ratio = ratio[0..5] if ratio.length > 5
    rescue ZeroDivisionError
      ratio = "0"
    end
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
  # http://chart.apis.google.com/chart?chs=130x50&cht=gom&chf=bg,s,f8f8f8&chco=8080ff,ff8080&chl=LOVE&chd=t:0
  def google_chart_url(label, ratio)
    "http://chart.apis.google.com/chart?chs=130x50&cht=gom&chf=bg,s,f8f8f8&chco=8080ff,ff8080&chl=#{label}&chd=t:#{ratio}"
  end
    
end
