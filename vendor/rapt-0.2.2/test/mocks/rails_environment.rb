
# Substitute since tests don't run under a real Rails app directory structure.
class RailsEnvironment
  def self.find(dir=nil); new(File.expand_path(File.dirname(__FILE__) + "/../sandbox/rails_app")); end
end
