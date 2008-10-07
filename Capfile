load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

#
# Update config/database.yml in the server
#
namespace :deploy do

  task :start, :roles => :app do
    run "cat ~/database.yml >> #{current_path}/config/database.yml"
  end

  task :restart, :roles => :app do
    run "cat ~/database.yml >> #{current_path}/config/database.yml"
  end

end


