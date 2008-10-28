# kick
# 
class LoadAverage
  attr_reader :uptime, :average1
  
  def initialize(uptime_path = '/usr/bin/uptime')
    @uptime_path = uptime_path
    @uptime, average1 = /up\s(.+?),.*es:\s(\d+\.\d+)/.match(`uptime`)[1..2]
    @average1 = average1.to_f
  end
  
end
