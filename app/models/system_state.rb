class SystemState < ActiveRecord::Base
  
  def self.current
    @current = self.find(:first)
  end
  
  def self.update_counters
    stat = @current ||= current
    stat.total_gem = Rubygem.find(:all).size
    stat.total_version = Version.find(:all).size
    stat.spec_counter = Spec.find(:all, :conditions => ["specs.yaml IS NOT NULL AND specs.yaml != ''"]).size
    stat.rdoc_counter = Version.find(:all, :conditions => ["versions.rdoc_path IS NOT NULL AND NOT versions.rdoc_path = ''"]).size
    stat.diagram_counter = Version.find(:all, :conditions => ["versions.diagram_path IS NOT NULL AND NOT versions.diagram_path = ''"]).size
    stat.save
  end
  
  def self.update_rdocs_now
    stat = @current ||= current
    stat.last_update_rdocs = Time.now
    stat.save
  end
  
  def self.choose_help_gems
    stat = @current ||= current
    help_gems = []
    worst1000 = Rubygem.find(:all, {:include => [:general_point], :limit => 1000, :order => "general_points.point DESC"})
    10.times do
      choose_order = rand(1000)
      if help_gems.include?(choose_order)
        redo
      else
        help_gems << worst1000[choose_order].id
      end
    end
    stat.help_gems = help_gems.join(',')
    stat.save
  end
end
