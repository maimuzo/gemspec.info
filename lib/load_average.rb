# kick
# 
class LoadAverage
  attr_reader :uptime, :average1
  
  def initialize(uptime_path = '/usr/bin/uptime')
    @uptime, average1 = /up\s(.+?),.*e:\s(\d+\.\d+)/.match(`#{uptime_path}`)[1..2]
    @average1 = average1.to_f
  end
  
end
