require 'open-uri'

class Plugin
  attr_reader :name, :uri, :versions
  
  def initialize(uri, name=nil)
    @uri = normalise_uri(uri)
    name.nil? ? guess_name(uri) : @name = name
    check_for_versions
  end
  
  def self.find(name)
    name =~ /\// ? new(name) : Repositories.instance.find_plugin(name)
  end
  
  def to_s
    "#{@name.ljust(30)}#{@uri}"
  end
  
  def svn_url?
    @uri =~ /svn(?:\+ssh)?:\/\/*/
  end
  
  def installed?
    File.directory?("#{rails_env.root}/vendor/plugins/#{name}") \
      or rails_env.externals.detect{ |name, repo| self.uri == repo }
  end
  
  def install(method=nil, options = {})
    options = {:version => "bleeding_edge"}.merge(options)

    method ||= rails_env.best_install_method?
    method   = :export if method == :http and svn_url?

    uninstall if installed? and options[:force]

    unless installed?
      send("install_using_#{method}", options)
      run_install_hook
    else
      puts "already installed: #{name} (#{uri}).  pass --force to reinstall"
    end
  end

  def uninstall
    path = "#{rails_env.root}/vendor/plugins/#{name}"
    if File.directory?(path)
      puts "Removing 'vendor/plugins/#{name}'" if $verbose
      run_uninstall_hook
      rm_r path
    else
      puts "Plugin doesn't exist: #{path}"
    end
    # clean up svn:externals
    externals = rails_env.externals
    externals.reject!{|n,u| name == n or name == u}
    rails_env.externals = externals
  end

  # Returns a hash representing this plugin's metadata
  def about(force_refresh=false)
    # Look in cache first
    unless force_refresh
      if Repositories.instance.source_cache['plugins'].has_key?(name)
        return Repositories.instance.source_cache['plugins'][name]
      end
    end
    # Get from original source
    tmp = "#{rails_env.root}/_tmp_about.yml"
    if svn_url?
      cmd = %(svn export #{@uri}/about.yml "#{tmp}")
      puts cmd if $verbose
      system(cmd)
    end
    about_uri = svn_url? ? tmp : File.join(@uri, 'about.yml')
    open(about_uri) do |stream|
      about_hash = YAML.load(stream.read)
      unless about_hash.is_a?(Hash) && !about_hash['plugin'].nil?
        raise("#{name}'s about.yml wasn't valid YAML")
      end
      return about_hash
    end 
  rescue
    # Make yaml on the fly for this plugin. 
    # The 'plugin' field (uri to the resource) is the only required field.
    {
      'plugin' => uri
    }
  ensure
    FileUtils.rm_rf tmp if svn_url?
  end

  private 

    def run_install_hook
      install_hook_file = "#{rails_env.root}/vendor/plugins/#{name}/install.rb"
      load install_hook_file if File.exists? install_hook_file
    end

    def run_uninstall_hook
      uninstall_hook_file = "#{rails_env.root}/vendor/plugins/#{name}/uninstall.rb"
      load uninstall_hook_file if File.exists? uninstall_hook_file
    end

    def install_using_export(options = {})
      svn_command :export, options
    end
    
    def install_using_checkout(options = {})
      svn_command :checkout, options
    end
    
    def install_using_externals(options = {})
      externals = rails_env.externals
      externals.push([@name, version_uri(options[:version])])
      rails_env.externals = externals
      install_using_checkout(options)
    end

    def install_using_http(options = {})
      root = rails_env.root
      mkdir_p "#{root}/vendor/plugins"
      Dir.chdir "#{root}/vendor/plugins"
      puts "fetching from '#{version_uri(options[:version])}'" if $verbose
      fetcher = get_http_fetcher(version_uri(options[:version]), options[:quiet])
      fetcher.fetch(version_uri(options[:version]))
      rename_version_to_name(options[:version], options[:quiet])
    end

    def svn_command(cmd, options = {})
      root = rails_env.root
      mkdir_p "#{root}/vendor/plugins"
      base_cmd = "svn #{cmd} #{version_uri(options[:version])} \"#{root}/vendor/plugins/#{name}\""
      base_cmd += ' -q' if options[:quiet] and not $verbose
      base_cmd += " -r #{options[:revision]}" if options[:revision] and (options[:version] == "bleeding_edge")
      puts base_cmd if $verbose
      system(base_cmd)
    end

    def guess_name(url)
      @name = File.basename(url)
      if @name == 'trunk' || @name.empty?
        @name = File.basename(File.dirname(url))
      end
    end
    
    def rails_env
      @rails_env || RailsEnvironment.default
    end
    
    def get_http_fetcher(uri, quiet=true)
      fetcher = RecursiveHTTPFetcher.new(uri)
      fetcher.quiet = quiet
      return fetcher
    end
    
    def check_for_versions
      if svn_url?
        check_svn_versions
      else
        check_http_versions
      end      
    end
    
    # TODO
    def check_svn_versions
      @versions = {"bleeding_edge" => ""}
    end
    
    def check_http_versions
      fetcher = get_http_fetcher(@uri)
      folders = fetcher.ls
      if has_trunk?(folders)
        @versions = {"bleeding_edge" => "trunk/"}
        if has_tags?(folders)
          tag_fetcher = get_http_fetcher("#{@uri}tags/")
          available_tags = tag_fetcher.ls.collect { |tag| tag.gsub("/", "") }
          available_tags.each { |tag| @versions[tag] = "tags/#{tag}/" }
        end
      else
        @versions = {"bleeding_edge" => ""}
      end
    end
    
    def version_uri(version)
      @uri + @versions[version]
    end
    
    def has_trunk?(plugin_root_list)
      plugin_root_list.grep(/trunk/).size == 1
    end
    
    def has_tags?(plugin_root_list)
      plugin_root_list.grep(/tags/).size == 1
    end
    
    # make sure uris always have a trailing slash
    def normalise_uri(uri)
      return (uri[-1, 1] == "/" ? uri : uri + '/')
    end
    
    def rename_version_to_name(version, quiet=false)
      return if @versions[version].empty?
      installed_folder = (version == "bleeding_edge") ? "trunk" : version
      puts "+ Renaming #{installed_folder} to #{name}" unless quiet and not $verbose
      FileUtils.mv("#{rails_env.root}/vendor/plugins/#{installed_folder}",
                   "#{rails_env.root}/vendor/plugins/#{name}")
    end
end
