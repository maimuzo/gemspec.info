# kick
# script/runner -e production 'GemspecBatch.new.setup("~/rails_app/gemspec.info/first_gem_pack.zip")' / maybe you can not run
# script/runner -e production 'GemspecBatch.new.update_contents' / every 10 minites
# script/runner -e production 'GemspecBatch.new.update_gems' / every 6 hours
#
# crontab
# */10 * * * * /usr/local/bin/ruby /(replace to your RAILS_HOME)/gemspec.info/current/script/runner -e production 'GemspecBatch.new(true).update_contents'
# 4 */6 * * * /usr/local/bin/ruby /(replace to your RAILS_HOME)/script/runner -e production 'GemspecBatch.new.update_gems'
#
class GemspecBatch
  def initialize(verbose = false)
    @verbose = verbose
  end

  def setup(zip_path)
    sync_from_core
    # TODO:need to get clone_sites from core.gemspec.info
    CloneSite.create({:name => "gemspec.info", :domain => "gemspec.info", :country => "Japan"})
    
    # Get gem and version list
    SpecParser.new(@verbose, @verbose).scan.add_unknown_gem_versions
    # Initialize slugs
    #`rake friendly_id:make_slugs`
    
    # Get specs from zip file
    SpecPackager.new(@verbose).unpack(zip_path)
    # at last, update specs
    SpecParser.new(@verbose, @verbose).load_from_ar.parse_agein_from_saved_yaml
    
    # Initialize records
    allow_openid_providers = [
      "fromnorth.blogspot.com", 
      "maimuzo.openid.ne.jp", 
      "maimuzo.myopenid.com",
      "http://www.hatena.ne.jp/maimuzo/",
      "https://mixi.jp/",
      "https://me.yahoo.co.jp/a/vTJHT7J6VKo2WSb1DUPq4fncKWT97jg-",
      "https://me.yahoo.com/a/WnsGs_d9l97N.B7eSplbAS4GJoc-",
      "http://profile.jugemkey.jp/USER_ID",
      "http://USER_ID.livejournal.com/",
      "http://technorati.com/people/technorati/USER_ID",
      "http://USER_ID.vox.com/",
      "http://profile.livedoor.com/maimuzo"
    ]
    allow_openid_providers.each do |op| add_op(op) end
    
    
    GeneralRankUpdater.new(@verbose).update
  end
  
  def update_contents
    ReferenceUpdater.new(@verbose).update
  end
  
  def update_gems
    sync_from_core
    # SpecParser.new(@verbose, @verbose).scan.update_spec_from_command
    GeneralRankUpdater.new(@verbose).update
  end
  
protected

  def add_op(op_url)
    Endpoint.new(@verbose).find(op_url).each {|e| TrastedOpenidProvider.create(:endpoint_url => e)}
  end
  
  def sync_from_core
    # TODO:
  end
end
