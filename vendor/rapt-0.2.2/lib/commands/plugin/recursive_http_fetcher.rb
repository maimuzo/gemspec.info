require 'open-uri'
require 'fileutils'

class RecursiveHTTPFetcher
  attr_accessor :quiet
  def initialize(urls_to_fetch, cwd = ".")
    @cwd = cwd
    @urls_to_fetch = urls_to_fetch.to_a
    @quiet = false
  end

  def ls
    @urls_to_fetch.collect do |url|
      if url =~ /^svn:\/\/.*/
        `svn ls #{url}`.split("\n").map {|entry| "/#{entry}"} rescue nil
      else
        open(url) do |stream|
          links("", stream.read)
        end rescue nil
      end
    end.flatten
  end

  def push_d(dir)
    @cwd = File.join(@cwd, dir)
    FileUtils.mkdir_p(@cwd)
  end

  def pop_d
    @cwd = File.dirname(@cwd)
  end

  def links(base_url, contents)
    links = []
    contents.scan(/href\s*=\s*\"*[^\">]*/i) do |link|
      link = link.sub(/href="/i, "")
      next if link =~ /^http/i || link =~ /^\./
      links << File.join(base_url, link)
    end
    links
  end
  
  def download(link)
    puts "+ #{File.join(@cwd, File.basename(link))}" unless @quiet
    open(link) do |stream|
      File.open(File.join(@cwd, File.basename(link)), "wb") do |file|
        file.write(stream.read)
      end
    end
  end
  
  def fetch(links = @urls_to_fetch)
    links.each do |l|
      (l =~ /\/$/ || links == @urls_to_fetch) ? fetch_dir(l) : download(l)
    end
  end
  
  def fetch_dir(url)
    push_d(File.basename(url))
    open(url) do |stream|
      contents =  stream.read
      fetch(links(url, contents))
    end
    pop_d
  end
end
