
# Load default environment and parse arguments
require 'optparse'
module Commands

  class Plugin
    attr_reader :environment, :script_name, :sources
    def initialize
      @environment = RailsEnvironment.default
      @rails_root = RailsEnvironment.default.root
      @script_name = File.basename($0) 
      @sources = []
    end
    
    def environment=(value)
      @environment = value
      RailsEnvironment.default = value
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@script_name} [OPTIONS] command"
        o.define_head "Rails plugin manager."
        
        o.separator ""        
        o.separator "GENERAL OPTIONS"
        
        o.on("-r", "--root=DIR", String,
             "Set an explicit rails app directory.",
             "Default: #{@rails_root}") { |@rails_root| self.environment = RailsEnvironment.new(@rails_root) }
        o.on("-s", "--source=URL1,URL2", Array,
             "Use the specified plugin repositories instead of the defaults.") { |@sources|}
        
        o.on("-v", "--verbose", "Turn on verbose output.") { |$verbose| }
        o.on("-h", "--help", "Show this help message.") { puts o; exit }
        
        o.separator ""
        o.separator "COMMANDS"
        
        o.separator "  discover       Discover plugin repositories."
        o.separator "  list           List available plugins."
        o.separator "  search         Search for available plugins."
        o.separator "  about          Show basic info about a plugin."
        o.separator "  install        Install plugin(s) from known repositories or URLs."
        o.separator "  update         Update installed plugins."
        o.separator "  remove         Uninstall plugins."
        o.separator "  source         Add a plugin source repository."
        o.separator "  unsource       Remove a plugin repository."
        o.separator "  sources        List currently configured plugin repositories."
        o.separator "  pack:install   Install plugins from plugin pack file or URL"
        o.separator "  pack:uninstall Uninstall plugins from plugin pack file or URL"
        o.separator "  pack:about     Display plugin pack information"
        
        o.separator ""
        o.separator "EXAMPLES"
        o.separator "  Install a plugin:"
        o.separator "    #{@script_name} install continuous_builder\n"
        o.separator "  Install a plugin from a subversion URL:"
        o.separator "    #{@script_name} install http://dev.rubyonrails.com/svn/rails/plugins/continuous_builder\n"
        o.separator "  Install a plugin and add a svn:externals entry to vendor/plugins"
        o.separator "    #{@script_name} install -x continuous_builder\n"
        o.separator "  Show information about the acts_as_chunky_bacon plugin:"
        o.separator "    #{@script_name} about acts_as_chunky_bacon\n"
        o.separator "  List all available plugins:"
        o.separator "    #{@script_name} list\n"
        o.separator "  List plugins in the specified repository:"
        o.separator "    #{@script_name} list --source=http://dev.rubyonrails.com/svn/rails/plugins/\n"
        o.separator "  Search available plugins:"
        o.separator "    #{@script_name} search \"authentication\"\n"
        o.separator "  Discover and prompt to add new repositories:"
        o.separator "    #{@script_name} discover\n"
        o.separator "  Discover new repositories but just list them, don't add anything:"
        o.separator "    #{@script_name} discover -l\n"
        o.separator "  Add a new repository to the source list:"
        o.separator "    #{@script_name} source http://dev.rubyonrails.com/svn/rails/plugins/\n"
        o.separator "  Remove a repository from the source list:"
        o.separator "    #{@script_name} unsource http://dev.rubyonrails.com/svn/rails/plugins/\n"
        o.separator "  Show currently configured repositories:"
        o.separator "    #{@script_name} sources\n"        
        o.separator "  Show the options for the list command:"
        o.separator "    #{@script_name} list -h\n"
        o.separator "  Install a plugin pack:"
        o.separator "    #{@script_name} pack:install http://opensource.agileevolved.com/pluginpacks/standard.pluginpack\n"
        o.separator "  View plugin pack meta data:"
        o.separator "    #{@script_name} pack:about http://opensource.agileevolved.com/pluginpacks/standard.pluginpack\n"
      end
    end
    
    def parse!(args=ARGV)
      general, sub = split_args(args)
      options.parse!(general)
      
      command = general.shift
      if command =~ /^(list|discover|install|source|unsource|sources|remove|update|about|search)$/
        command = Commands.const_get(command.capitalize).new(self)
        command.parse!(sub)
      elsif command =~ /^(pack:install|pack:uninstall|pack:about)$/
        command_name = command.split(':')[1]
        command = Commands::Pack.const_get(command_name.capitalize).new(self)
        command.parse!(sub)
      else
        puts "Unknown command: #{command}"
        puts options
        exit 1
      end
    end
    
    def split_args(args)
      left = []
      left << args.shift while args[0] and args[0] =~ /^-/
      left << args.shift if args[0]
      return [left, args]
    end
    
    def self.parse!(args=ARGV)
      Plugin.new.parse!(args)
    rescue NoMethodError
      puts "Error: RaPT currently does not work outside of a Rails application directory.  Please change to the top level of a Rails application and try again."
    end
  end
  
  
  class List
    def initialize(base_command)
      @base_command = base_command
      @sources = []
      @local = false
      @remote = false
      @cached = true
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} list [OPTIONS] [PATTERN]"
        o.define_head "List available plugins."
        o.separator   ""        
        o.separator   "Options:"
        o.separator   ""
        o.on(         "-s", "--source=URL1,URL2", Array,
                      "Use the specified plugin repositories.") {|@sources| @remote = true; @cached = false }
        o.on(         "--local", 
                      "List locally installed plugins.") {|@local| @cached = false }
        o.on(         "--cached",
                      "List the known plugins in the local sources cache. This is the default behavior.") {|@cached|}
        o.on(         "--remote",
                      "List remotely available plugins.",
                      "unless --local is provided.") {|@remote| @cached = false }
      end
    end
    
    def parse!(args)
      options.order!(args)
      unless @sources.empty?
        @sources.map!{ |uri| Repository.new(uri) }
      else
        @sources = Repositories.instance.all
      end
      if @remote
        @sources.map{|r| r.plugins}.flatten.each do |plugin| 
          if @local or !plugin.installed?
            puts plugin.to_s
          end
        end
      elsif @cached
        Repositories.instance.cached_plugins.each { |plugin| puts plugin.to_s }
        puts "\nThere are #{Repositories.instance.plugin_count} plugins in the source cache.\n\n"
      else
        cd "#{@base_command.environment.root}/vendor/plugins"
        Dir["*"].select{|p| File.directory?(p)}.each do |name| 
          puts name
        end
      end
    end
  end
  
  
  class Sources
    def initialize(base_command)
      @base_command = base_command
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} sources [OPTIONS] [PATTERN]"
        o.define_head "List configured plugin repositories."
        o.separator   ""        
        o.separator   "Options:"
        o.separator   ""
        o.on(         "-c", "--check", 
                      "Report status of repository.") { |@sources| } # TODO Implement
        o.on(         "-r", "--refresh", 
                      "Refresh the source cache with the list of plugins available in each repository.") { refresh }
      end
    end
    
    def parse!(args)
      options.parse!(args)
      Repositories.each do |repo|
        puts repo.uri
      end
    end
    
    def refresh
      puts "Refreshing source cache (may take a few minutes)..."
      repositories = Repositories.instance
      repositories.refresh!
      repositories.save
    end
  end
  
  
  class Source
    def initialize(base_command)
      @base_command = base_command
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} source REPOSITORY"
        o.define_head "Add a new repository."
      end
    end
    
    def parse!(args)
      options.parse!(args)
      count = 0
      args.each do |uri|
        if Repositories.instance.add(uri)
          puts "added: #{uri.ljust(50)}" if $verbose
          count += 1
        else
          puts "failed: #{uri.ljust(50)}"
        end
      end
      Repositories.instance.save
      puts "Added #{count} repositories."
    end
  end
  
  
  class Unsource
    def initialize(base_command)
      @base_command = base_command
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} source URI [URI [URI]...]"
        o.define_head "Remove repositories from the default search list."
        o.separator ""
        o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
      end
    end
    
    def parse!(args)
      options.parse!(args)
      count = 0
      args.each do |uri|
        if Repositories.instance.remove(uri)
          count += 1
          puts "removed: #{uri.ljust(50)}"
        else
          puts "failed: #{uri.ljust(50)}"
        end
      end
      Repositories.instance.save
      puts "Removed #{count} repositories."
    end
  end

  
  class Discover
    def initialize(base_command)
      @base_command = base_command
      @list = false
      @prompt = true
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} discover URI [URI [URI]...]"
        o.define_head "Discover repositories referenced on a page."
        o.separator   ""        
        o.separator   "Options:"
        o.separator   ""
        o.on(         "-l", "--list", 
                      "List but don't prompt or add discovered repositories.") { |@list| @prompt = !@list }
        o.on(         "-n", "--no-prompt", 
                      "Add all new repositories without prompting.") { |v| @prompt = false }
      end
    end

    def parse!(args)
      options.parse!(args)
      args = ['http://wiki.rubyonrails.org/rails/pages/Plugins', 'http://agilewebdevelopment.com/plugins/scrape'] if args.empty?
      args.each do |uri|
        scrape(uri) do |repo_uri|
          catch(:next_uri) do
            if @prompt
              begin
                $stdout.print "Add #{repo_uri}? [Y/n] "
                throw :next_uri if $stdin.gets !~ /^y?$/i
              rescue Interrupt
                $stdout.puts
                exit 1
              end
            elsif @list
              puts repo_uri
              throw :next_uri
            end
            Repositories.instance.add(repo_uri)
            puts "discovered: #{repo_uri}" if $verbose or !@prompt
          end
        end
      end
      Repositories.instance.save
    end
    
    def scrape(uri)
      require 'open-uri'
      puts "Scraping #{uri}" if $verbose
      dupes = []
      content = open(uri).each do |line|
        begin
          if line =~ /<a[^>]*href=['"]([^'"]*)['"]/ || line =~ /(svn:\/\/[^<|\n]*)/
            uri = $1
            if uri =~ /^\w+:\/\// && uri =~ /\/plugins\// && uri !~ /\/browser\// && uri !~ /^http:\/\/wiki\.rubyonrails/ && uri !~ /http:\/\/instiki/
              uri = extract_repository_uri(uri)
              yield uri unless dupes.include?(uri) || Repositories.instance.exist?(uri)
              dupes << uri
            end
          end
        rescue
          puts "Problems scraping '#{uri}': #{$!.to_s}"
        end
      end
    end
    
    def extract_repository_uri(uri)
      uri.match(/(svn|https?):.*\/plugins\//i)[0]
    end 
  end
  
  class Install
    @@default_method = :http
    
    def initialize(base_command)
      @base_command = base_command
      @method = @@default_method
      @options = { :quiet => false, :revision => nil, :force => false, :force_http => false }
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} install PLUGIN [PLUGIN [PLUGIN] ...]"
        o.define_head "Install one or more plugins."
        o.separator   ""
        o.separator   "Options:"
        o.on(         "-x", "--externals", 
                      "Use svn:externals to grab the plugin.", 
                      "Enables plugin updates and plugin versioning.") { |v| @method = :externals }
        o.on(         "-o", "--checkout",
                      "Use svn checkout to grab the plugin.",
                      "Enables updating but does not add a svn:externals entry.") { |v| @method = :checkout }
        o.on(         "-q", "--quiet",
                      "Suppresses the output from installation.",
                      "Ignored if -v is passed (./script/plugin -v install ...)") { |v| @options[:quiet] = true }
        o.on(         "-r REVISION", "--revision REVISION",
                      "Checks out the given revision from subversion.",
                      "Ignored if subversion is not used.") { |v| @options[:revision] = v }
        o.on(         "-f", "--force",
                      "Reinstalls a plugin if it's already installed.") { |v| @options[:force] = true }
        o.on(         "-c", "--svn",
                      "Modify files with subversion. (Note: svn must be in path)") { |v| @options[:svn] = true }
        o.on(         "-h", "--force-http",
                      "Forces download in HTTP mode") { |v| @options[:force_http] = true }
        o.on(         "--version",
                      "Install a specific version of a plugin") { |v| @options[:version] = v }
        o.separator   ""
        o.separator   "You can specify plugin names as given in 'plugin list' output or absolute URLs to "
        o.separator   "a plugin repository."
      end
    end
    
    def determine_install_method
      return :http if @options[:force_http]
      best = @base_command.environment.best_install_method?
      @method = @@default_method if best == :http and @method == :export
      case
      when (best == :http and @method != :http)
        msg = "Cannot install using subversion because `svn' cannot be found in your PATH"
      when (best == :export and (@method != :export and @method != :http))
        msg = "Cannot install using #{@method} because this project is not under subversion."
      when (best != :externals and @method == :externals)
        msg = "Cannot install using externals because vendor/plugins is not under subversion."
      end
      if msg
        puts msg
        exit 1
      end
      @method
    end
    
    def parse!(args)
      options.parse!(args)
      environment = @base_command.environment
      install_method = determine_install_method
      puts "Plugins will be installed using #{install_method}" if $verbose
      args.each do |name|
        plugin = ::Plugin.find(name)
        if @options[:version]
          if plugin.versions[@options[:version]].nil?
            puts "Invalid plugin version."
            exit 1
          end
        else
          set_chosen_version(plugin)
        end
        plugin.install(install_method, @options)
        environment.add_plugin_to_svn(plugin.name) if @options[:svn]
      end
    #rescue
    #  puts "Plugin not found: #{args.inspect}"
    #  exit 1
    end
    
    def get_version(versions)
      prompt = "Multiple versions found, which version would you like to install?\n"
      index = 1
      versions.keys.sort.reverse.each{ |version| prompt << "#{index.to_s}. #{version}\n"; index = index.next }
      selected_version = nil
      while selected_version.nil?
        puts prompt
        print "> "
        selected_version = prompt_for_version
        selected_version = nil unless (1..versions.size).include?(selected_version.to_i)
      end
      return versions.keys.sort.reverse[selected_version-1]
    end
    
    def prompt_for_version
      ARGV.pop
      gets.strip.to_i
    end
    
    def set_chosen_version(plugin)
      if plugin.versions.size > 1
        @options[:version] = get_version(plugin.versions)
      else
        @options[:version] = plugin.versions.keys.first
      end
    end
  end

  class Update
    def initialize(base_command)
      @base_command = base_command
    end
   
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} update [name [name]...]"
        o.on(         "-r REVISION", "--revision REVISION",
                      "Checks out the given revision from subversion.",
                      "Ignored if subversion is not used.") { |v| @revision = v }
        o.define_head "Update plugins."
      end
    end
   
    def parse!(args)
      options.parse!(args)
      root = @base_command.environment.root
      cd root
      args = Dir["vendor/plugins/*"].map do |f|
        File.directory?("#{f}/.svn") ? File.basename(f) : nil
      end.compact if args.empty?
      cd "vendor/plugins"
      args.each do |name|
        if File.directory?(name)
          puts "Updating plugin: #{name}"
          system("svn #{$verbose ? '' : '-q'} up \"#{name}\" #{@revision ? "-r #{@revision}" : ''}")
        else
          puts "Plugin doesn't exist: #{name}"
        end
      end
    end
  end

  class Remove
    def initialize(base_command)
      @base_command = base_command
    end
    
    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} remove name [name]..."
        o.define_head "Remove plugins."
      end
    end
    
    def parse!(args)
      options.parse!(args)
      root = @base_command.environment.root
      args.each do |name|
        ::Plugin.new(name).uninstall
      end
    end
  end

  class About
    def initialize(base_command)
      @base_command = base_command
    end

    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} about name [name]..."
        o.define_head "Shows plugin info at {url}/about.yml."
      end
    end

    def parse!(args)
      options.parse!(args)
      args.each do |name|
        if plugin = ::Plugin.find(name)
          if about_hash = plugin.about
            puts about_hash.to_yaml + "\n"
            next
          end
        end
        
        puts "Plugin #{name} could not be found in the known repositories."
        puts
      end
    end
  end

  class Search
    require 'net/http'
    require 'rexml/document' 
    
    def initialize(base_command)
      @base_command = base_command
      @directory = "http://agilewebdevelopment.com/plugins/search?search=%s"
    end

    def options
      OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    "Usage: #{@base_command.script_name} search \"search string\""
        o.on(         "-d DIRECTORY", "--directory DIRECTORY",
                      "Queries the URL specified by DIRECTORY.") { |v| @directory = v }
        o.define_head "Search plugins."
      end
    end

    def parse!(args)
      options.parse!(args)
      uri = URI.parse(@directory % URI.escape(args.first))
      request = Net::HTTP.new(uri.host, uri.port)
      root = REXML::Document.new(request.send_request('GET', uri.request_uri, nil, 'Accept' => 'application/xml').body).root 
      root.elements.each('plugin') do |p|
        puts p.elements['name'].text
        puts "  Info: #{p.elements['link'].text}"
        puts "  Install: #{p.elements['repository'].text}"
      end
    rescue
      nil
    end
  end
  
  module Pack
    class Install
      def initialize(base_command)
        @base_command = base_command
      end
      
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} pack:install pack_file_or_url"
          o.define_head "Installs plugin pack at pack_file_or_url"
        end
      end
      
      def parse!(args)
        uri = args.first
        plugin_pack = PluginPackParser.parse_spec_file(uri)
        plugin_pack.plugins.each do |plugin|
          puts "+ [Adding] #{plugin.name}"
          plugin.install
        end
      end
    end
    
    class Uninstall
      def initialize(base_command)
        @base_command = base_command
      end
      
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} pack:uninstall pack_file_or_url"
          o.define_head "Uninstalls plugin pack at pack_file_or_url"
        end
      end
      
      def parse!(args)
        uri = args.first
        plugin_pack = PluginPackParser.parse_spec_file(uri)
        plugin_pack.plugins.each do |plugin|
          puts "+ [Removing] #{plugin.name}"
          plugin.uninstall
        end
      end
    end
    
    class About
      def initialize(base_command)
        @base_command = base_command
      end
      
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} pack:about pack_file_or_url"
          o.define_head "Shows meta-data and plugin list for plugin pack at pack_file_or_url"
        end
      end
      
      def parse!(args)
        uri = args.first
        plugin_pack = PluginPackParser.parse_spec_file(uri)
        display_meta(plugin_pack)
        display_plugins(plugin_pack)
      end
      
      protected
        def display_meta(plugin_pack)
          puts "Retrieving information for plugin pack #{plugin_pack.name}"
          [:description, :author, :email, :website].each do |info_attr|
            info = plugin_pack.send(info_attr)
            unless info.nil? or info.empty?
              puts "* #{info_attr.to_s.capitalize}: #{info}"
            end
          end
        end
        
        def display_plugins(plugin_pack)
          puts "Pack contents:"
          plugin_pack.plugins.each do |plugin|
            puts "* #{plugin.name}"
          end
        end
    end
  end
end
 
