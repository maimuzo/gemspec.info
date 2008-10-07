namespace :acts_as_taggable do 
  # add by Maimuzo
  require 'environment'
  require 'rails_generator' 
  require 'rails_generator/scripts/generate'
  
  namespace :db do  
 	  desc "Creates tag tables for use with acts_as_taggable" 
    task :create => :environment do 
      raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations? 
      Rails::Generator::Scripts::Generate.new.run([ "acts_as_taggable_tables", "add_acts_as_taggable_tables" ])
    end 
  end
  
  namespace :stylesheet do
    desc "Create tag stylesheet for use with acts_as_taggable"
    task :create do
      Rails::Generator::Scripts::Generate.new.run([ "acts_as_taggable_stylesheet" ])
    end
  end
end
