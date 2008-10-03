require 'yaml'

class Repositories
  include Enumerable

  attr_accessor :source_cache
  
  def initialize(cache_file = File.join(find_home, ".rails", "plugin_source_cache.yml"))
    @cache_file = File.expand_path(cache_file)
    load!
  end
  
  def each(&block)
    @repositories.each(&block)
  end
  
  def add(uri)
    unless find { |repo| repo.uri == uri }
      repository = Repository.new(uri)
      refresh_repository!(repository)
      @repositories.push(repository).last
    end
  end
  
  def remove(uri)
    @repositories.reject!{|repo| repo.uri == uri}
  end
  
  def exist?(uri)
    @repositories.detect{|repo| repo.uri == uri }
  end
  
  def all
    @repositories
  end
  
  def find_plugin(name)
    # Try to get plugin from cache first
    if @source_cache['plugins'].has_key?(name) && @source_cache['plugins'][name].has_key?('plugin')
      return Plugin.new(@source_cache['plugins'][name]['plugin'], name)
    end
    
    @repositories.each do |repo|
      repo.each do |plugin|
        return plugin if plugin.name == name
      end
    end
    return nil
  end

  # List the known plugins from the sources cache.
  def cached_plugins
    @source_cache['plugins'].keys.sort.map do |plugin_name| 
      Plugin.new(@source_cache['plugins'][plugin_name]['plugin'], plugin_name)
    end
  end

  # Returns the number of known plugins in the cache.
  def plugin_count
    source_cache['plugins'].keys.length
  rescue
    0
  end
  
  # Gets the updated list of plugins available at each repository.
  def refresh!
    @repositories.each { |repo| refresh_repository!(repo) }
  end

  # Gets the list of plugins available at this repository.
  def refresh_repository!(repository)
    repository.plugins.each do |plugin|
      if about_hash = plugin.about(true)
        @source_cache['plugins'][plugin.name] = about_hash
      end
    end    
  end
  
  
  def load!
    @source_cache = File.exist?(@cache_file) ? YAML.load(File.read(@cache_file)) : defaults
    @source_cache = defaults if @source_cache.keys.nil?
    @repositories = @source_cache['repositories'].map { |source| Repository.new(source.strip) }
  end
  
  def save
    mkdir_p(File.dirname(@cache_file)) unless File.exist?(File.dirname(@cache_file))
    File.open(@cache_file, 'w') do |f|
      @source_cache['repositories'] = @repositories.map {|r| r.uri }.uniq
      f.write(@source_cache.to_yaml)
      f.write("\n")
    end
  end
  
  def defaults
    {
      'repositories' => ['http://dev.rubyonrails.com/svn/rails/plugins/'],
      'plugins' => {}
      }
  end
 
  def find_home
    ['HOME', 'USERPROFILE'].each do |homekey|
      return ENV[homekey] if ENV[homekey]
    end
    if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      return "#{ENV['HOMEDRIVE']}:#{ENV['HOMEPATH']}"
    end
    begin
      File.expand_path("~")
    rescue StandardError => ex
      if File::ALT_SEPARATOR
        "C:/"
      else
        "/"
      end
    end
  end

  def self.instance
    # TODO Use test cache file if $testing
    @instance ||= Repositories.new
  end
  
  def self.each(&block)
    self.instance.each(&block)
  end
end
