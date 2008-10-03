# Rails Plugin Manager.
# 
# Listing available plugins:
#
#   $ ./script/plugin list
#   continuous_builder            http://dev.rubyonrails.com/svn/rails/plugins/continuous_builder
#   asset_timestamping            http://svn.aviditybytes.com/rails/plugins/asset_timestamping
#   enumerations_mixin            http://svn.protocool.com/rails/plugins/enumerations_mixin/trunk
#   calculations                  http://techno-weenie.net/svn/projects/calculations/
#   ...
#
# Installing plugins:
#
#   $ ./script/plugin install continuous_builder asset_timestamping
#
# Finding Repositories:
#
#   $ ./script/plugin discover
# 
# Adding Repositories:
#
#   $ ./script/plugin source http://svn.protocool.com/rails/plugins/
#
# How it works:
# 
#   * Maintains a list of subversion repositories that are assumed to have
#     a plugin directory structure. Manage them with the (source, unsource,
#     and sources commands)
#     
#   * The discover command scrapes the following page for things that
#     look like subversion repositories with plugins:
#     http://wiki.rubyonrails.org/rails/pages/Plugins
# 
#   * Unless you specify that you want to use svn, script/plugin uses plain old
#     HTTP for downloads.  The following bullets are true if you specify
#     that you want to use svn.
#
#   * If `vendor/plugins` is under subversion control, the script will
#     modify the svn:externals property and perform an update. You can
#     use normal subversion commands to keep the plugins up to date.
# 
#   * Or, if `vendor/plugins` is not under subversion control, the
#     plugin is pulled via `svn checkout` or `svn export` but looks
#     exactly the same.
# 
# This is Free Software, copyright 2005 by Ryan Tomayko (rtomayko@gmail.com) 
# and is licensed MIT: (http://www.opensource.org/licenses/mit-license.php)

$verbose = false

require 'open-uri'
require 'fileutils'
require 'tempfile'

include FileUtils

require File.dirname(__FILE__) + '/plugin/rails_environment' 
require File.dirname(__FILE__) + '/plugin/plugin' 
require File.dirname(__FILE__) + '/plugin/repositories' 
require File.dirname(__FILE__) + '/plugin/repository' 
require File.dirname(__FILE__) + '/plugin/commands' 
require File.dirname(__FILE__) + '/plugin/recursive_http_fetcher' 
require File.dirname(__FILE__) + '/plugin/plugin_pack' 



