
class RailsEnvironment
  attr_reader :root

  def initialize(dir)
    @root = dir
  end

  def self.find(dir=nil)
    dir ||= pwd
    while dir.length > 1
      return new(dir) if File.exist?(File.join(dir, 'config', 'environment.rb'))
      dir = File.dirname(dir)
    end
  end
  
  def self.default
    @default ||= find
  end
  
  def self.default=(rails_env)
    @default = rails_env
  end
  
  def install(name_uri_or_plugin)
    if name_uri_or_plugin.is_a? String
      if name_uri_or_plugin =~ /:\/\// 
        plugin = Plugin.new(name_uri_or_plugin)
      else
        plugin = Plugins[name_uri_or_plugin]
      end
    else
      plugin = name_uri_or_plugin
    end
    unless plugin.nil?
      plugin.install
    else
      puts "plugin not found: #{name_uri_or_plugin}"
    end
  end
 
  def use_svn?
    require 'active_support/core_ext/kernel'
    silence_stderr {`svn --version` rescue nil}
    !$?.nil? && $?.success?
  end

  def use_externals?
    use_svn? && File.directory?("#{root}/vendor/plugins/.svn")
  end

  def use_checkout?
    # this is a bit of a guess. we assume that if the rails environment
    # is under subversion then they probably want the plugin checked out
    # instead of exported. This can be overridden on the command line
    File.directory?("#{root}/.svn")
  end

  def best_install_method?
    return :http unless use_svn?
    case
      when use_externals? then :externals
      when use_checkout? then :checkout
      else :export
    end
  end

  def externals
    return [] unless use_externals?
    ext = `svn propget svn:externals "#{root}/vendor/plugins"`
    ext.reject{ |line| line.strip == '' }.map do |line| 
      line.strip.split(/\s+/, 2) 
    end
  end

  def externals=(items)
    unless items.is_a? String
      items = items.map{|name,uri| "#{name.ljust(29)} #{uri.chomp('/')}"}.join("\n")
    end
    Tempfile.open("svn-set-prop") do |file|
      file.write(items)
      file.flush
      system("svn propset -q svn:externals -F \"#{file.path}\" \"#{root}/vendor/plugins\"")
    end
  end
  
  def add_plugin_to_svn(plugin_name)
    system("svn add #{root}/vendor/plugins/#{plugin_name}")
  end
end
