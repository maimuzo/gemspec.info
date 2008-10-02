require "rubygems"
require "pit"
personal = Pit.get("gemspec.info")

# default

set :application, "gemspec.info"
# set :repository,  "set your repository location here"

# set by my hand

set :user, personal["user"]
set :domain, "gemspec.info"

set :repository,  "#{user}@#{domain}:/home/#{user}/git/#{application}"
set :scm, :git
set :scm_username, user
set :runner, user
set :use_sudo, false
set :branch, "master"
set :deploy_via, :checkout
set :git_shallow_clone, 1
set :deploy_to, "/home/#{user}/rails_app/#{application}"
default_run_options[:pty] = true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, domain
role :web, domain
role :db,  domain, :primary => true
