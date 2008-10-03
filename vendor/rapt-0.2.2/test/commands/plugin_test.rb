require 'test/unit'
require 'rubygems'
require 'fileutils'
require 'stringio'
$testing = true
require File.dirname(__FILE__) + "/../../lib/commands/plugin"
require File.dirname(__FILE__) + "/../mocks/rails_environment"

class Commands::Install
  def self.default_method=(method)
    @@default_method = method
  end
  
  # dont want to use gets in test
  def prompt_for_version
    $selected_version
  end
end

# TODO Mock the remote repository so we don't have to hit an actual server for the plugins.
class Commands::PluginTest < Test::Unit::TestCase
  
  def setup
    @plugin_name = 'meta_tags'
    @remote_source = 'http://topfunky.net/svn/plugins'
    @captured_output = StringIO.new("")
  end
  
  def teardown
    $stdout = STDOUT
    Commands::Install.default_method = :http
    `svn revert #{plugin_directory} `
    `svn cleanup`
  end

  def test_list
    output = run_command('list', "--source=#{@remote_source}")
    %w(topfunky_power_tools ar_fixtures meta_tags gruff sparklines).each do |plugin|
      assert_match %r!#{plugin}!, output.to_yaml
    end
  end

  def test_sources
    output = run_command('sources')
    assert_match %r!http://dev.rubyonrails.com/svn/rails/plugins!, output.to_yaml
  end

  def test_about
    run_command('source', @remote_source)
      
    assert_nothing_raised {
      run_command('about', @plugin_name)
      run_command('about', 'exception_notification')
    }    
  end

  def xtest_install
    run_command('install', File.join(@remote_source, @plugin_name))
    assert File.exists?(path_to_plugin(@plugin_name) + "/lib"),
            "Plugin should have been installed at #{path_to_plugin(@plugin_name)}"
    
    output = run_command('list', "--local")
    assert_match %r!#{@plugin_name}!, output.to_yaml
        
    run_command('remove', @plugin_name)
    deny File.exists?(path_to_plugin(@plugin_name) + "/lib"),
            "Plugin should have been removed at #{path_to_plugin(@plugin_name)}"
  ensure
    FileUtils.rm_rf path_to_plugin(@plugin_name)
  end
  
  def test_install_with_svn_add
    run_command('install', "--svn", File.join(@remote_source, @plugin_name))
    assert File.exists?(path_to_plugin(@plugin_name) + "/lib"),
            "Plugin should have been installed at #{path_to_plugin(@plugin_name)}"
    output = `svn stat`.strip.split("\n")
    scan_directory(path_to_plugin(@plugin_name)) do |plugin_file|
      plugin_file.slice!(plugin_directory)
      assert_equal 1, output.grep(/^A[ ]+#{plugin_file}/).size
    end
    ensure
      FileUtils.rm_rf path_to_plugin(@plugin_name)
      `svn rm #{path_to_plugin(@plugin_name)}`
  end
  
  def test_install_with_forced_http
    $stdout = @captured_output
    $verbose = true
    Commands::Install.default_method = :externals # anything but http
    output = run_command('install', "--force-http", File.join(@remote_source, @plugin_name))
    assert File.exists?(path_to_plugin(@plugin_name) + "/lib"),
            "Plugin should have been installed at #{path_to_plugin(@plugin_name)}"
    assert @captured_output.string.include?("Plugins will be installed using http")
    $stdout = STDOUT
    ensure
      FileUtils.rm_rf path_to_plugin(@plugin_name)
  end
  
  def test_install_with_multiple_versions
    $selected_version = 1
    $verbose = true
    output = run_command("install", "http://opensource.agileevolved.com/svn/root/rails_plugins/unobtrusive_javascript")  
    assert File.exists?(path_to_plugin("unobtrusive_javascript") + "/lib")
    ensure
      FileUtils.rm_rf path_to_plugin("unobtrusive_javascript")
  end
  
  def test_install_with_specifc_version
    $stdout = @captured_output
    $selected_version = 1
    $verbose = true
    output = run_command("install", "--version=rel-0.1", "http://opensource.agileevolved.com/svn/root/rails_plugins/unobtrusive_javascript")  
    assert File.exists?(path_to_plugin("unobtrusive_javascript") + "/lib")
    assert @captured_output.string.include?("Renaming rel-0.1 to unobtrusive_javascript")
    $stdout = STDOUT
    ensure
      FileUtils.rm_rf path_to_plugin("unobtrusive_javascript")
  end

  # TODO Takes too long...find a way to speed it up
  # def test_sources
  #   assert_nothing_raised {
  #     run_command('sources', '--refresh')
  #   }
  # end

protected
  def scan_directory(dirname, &block)
    Dir.new(dirname).each do |entry|
      full_path = File.join(dirname, entry)
      if File.directory?(full_path)
        unless %w(.svn . ..).include?(entry)
          scan_directory(full_path, &block) 
        end
      else
        yield full_path
      end
    end
  end

  def deny(condition, message=nil)
    assert !condition, message
  end

  def run_command(*args)
    Commands::Plugin.parse! args    
  end

  # Returns the full path to a locally installed plugin
  def path_to_plugin(name)
    "#{plugin_directory}#{name}"
  end
  
  def plugin_directory
    RailsEnvironment.default.root + "/vendor/plugins/"
  end
end

