$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenidFu
  
end

Dir.glob(File.join(File.dirname(__FILE__), 'openid_fu/**/*.rb')).each do |path|
  require path
end
