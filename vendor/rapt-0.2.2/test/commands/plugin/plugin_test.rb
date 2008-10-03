require 'test/unit'
require 'rubygems'
$testing = true
require File.dirname(__FILE__) + "/../../../lib/commands/plugin"
require File.dirname(__FILE__) + "/../../mocks/rails_environment"

# TODO Mock the remote repository so we don't have to hit an actual server for the plugins.
class Commands::Plugin::PluginTest < Test::Unit::TestCase

  def setup
    @name = 'exception_notification'
    @uri = "http://dev.rubyonrails.org/svn/rails/plugins/#{@name}"
    @plugin = Plugin.new @uri, @name     
  end
  
  def test_name_and_uri
    assert_equal @name, @plugin.name
    assert_equal @uri, @plugin.uri
  end
  
  def test_versions
    assert_equal 1, @plugin.versions.size
    assert_equal "bleeding_edge", @plugin.versions.keys.first
  end
  
  def test_to_s
    assert_equal 'exception_notification        http://dev.rubyonrails.org/svn/rails/plugins/exception_notification/', @plugin.to_s
  end

  def test_find
    assert_equal @name, Plugin.find(@name).name
    assert_equal @name, Plugin.find(@uri).name, "Given a URI, a new plugin should be made and the name should be auto-discovered"
  end

  def test_svn_url_eh
    assert Plugin.new("svn://topfunky.net/svn/plugins/ar_fixtures").svn_url?, "A URL starting with svn: should be recognized as a Subversion URL"
  end

  def test_installed_eh
    assert !@plugin.installed?
  end

  def test_install
    @plugin.install :http
    assert @plugin.installed?

    @plugin.uninstall
    assert !@plugin.installed?
  ensure
    FileUtils.rm_rf RailsEnvironment.default.root + "/vendor/plugins/#{@name}"
  end

  def test_about
    assert_match %r!#{@uri}!, @plugin.about['plugin']
  end
  
  def test_about_should_return_uri_if_nonexistent
    fake_uri = 'http://topfunky.net/svn/plugins/nonexistent'
    p = Plugin.new(fake_uri)
    assert_equal fake_uri, p.about['plugin']
  end
  
end

class Commands::Plugin::PluginWithSubversionRepoStructureTest < Test::Unit::TestCase
  def setup
    @uri = "http://opensource.agileevolved.com/svn/root/rails_plugins/unobtrusive_javascript/"
    @name = "unobtrusive_javascript"
    @plugin = Plugin.new @uri, @name
  end
  
  def test_url_should_have_subversion_repo_structure
    fetcher = RecursiveHTTPFetcher.new(@uri)
    links = fetcher.ls
    assert !links.grep(/trunk/).empty?
    assert !links.grep(/tags/).empty?
    assert !links.grep(/branches/).empty?
  end
  
  def test_plugin_should_have_at_least_an_bleeding_edge_version
    # bleeding edge version == trunk
    assert @plugin.versions.keys.include?("bleeding_edge")
    assert_equal "trunk/", @plugin.versions["bleeding_edge"]
  end
  
  def test_should_have_tagged_versions
    assert @plugin.versions.keys.include?("rel-0.1")
    assert_equal "tags/rel-0.1/", @plugin.versions["rel-0.1"]
  end
  
  def test_installing_tagged_version
    $verbose = true
    @plugin.install :http, :version => "rel-0.1"
    assert @plugin.installed?
    
    @plugin.uninstall
    assert !@plugin.installed?
  end
end