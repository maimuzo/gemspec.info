class Repository
  include Enumerable
  attr_reader :uri, :plugins
  
  def initialize(uri)
    @uri = uri.chomp('/') << "/"
    @plugins = nil
  end
    
  def plugins
    unless @plugins
      if $verbose
        puts "Discovering plugins in #{@uri}" 
        puts index
      end

      @plugins = index.reject{ |line| line !~ /\/$/ }
      @plugins.map! { |name| name.gsub!("/", ""); Plugin.new(File.join(@uri, name), name) }
    end

    @plugins
  end
  
  def each(&block)
    plugins.each(&block)
  end
  
  private
    def index
      @index ||= RecursiveHTTPFetcher.new(@uri).ls
    end
end

