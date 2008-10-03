require 'test/unit'
require 'rubygems'
$testing = true
require File.dirname(__FILE__) + "/../../../lib/commands/plugin"
require File.dirname(__FILE__) + "/../../mocks/rails_environment"

# TODO Mock the remote repository so we don't have to hit an actual server for the plugins.
# LR: heres one way of sorting this out with a stub for the http fetcher
class RecursiveHTTPFetcher
  def ls
    ['/meta_tags/']
  end
end


class Commands::Plugin::RepositoryTest < Test::Unit::TestCase

  def setup
    @name = 'meta_tags'
    @uri = 'http://topfunky.net/svn/plugins'
  end

  def test_plugins
    r = Repository.new @uri
    assert r.plugins.map {|p| p.name }.include?(@name), "#{@name} should have been in the plugin list."
  end

end
