require 'open-uri'
require 'rubygems'
require 'extractcontent'

# kick
# script/runner 'ReferenceUpdater.new(true).update'
# script/runner -e production 'ReferenceUpdater.new.update'
class ReferenceUpdater
  
  @@maximum_retry = 3
  
  @@success_to_get_refernce_content_counter = 100
  @@can_not_get_refernce_content_counter = 50
  
  def initialize(verbose = false)
    @verbose = verbose
  end

=begin
      @comment.url = params[:obstacle][:url]
      @comment.tried_times = 0
      @comment.foreign_content = "コンテンツ取得中...\n(お急ぎの方は直接リンクをクリックしてください)"
      @comment.method = 'referenced'

=end  

  def update
    cond = [
      "method = 'referenced' AND tried_times < :maximum_retry",
      {:maximum_retry => @@maximum_retry}
    ]
    Comment.find(:all, :conditions => cond, :order => "updated_at ASC").each do |comment|
      begin
        target_html = get_content(comment.url)
        raise "fail to get html" if target_html.nil?
        comment.foreign_content = extract(target_html)
        comment.tried_times = @@success_to_get_refernce_content_counter
        raise "fail to save reference content"unless comment.save
        puts "success to get it." if @verbose
      rescue
        error_recovery(comment)
      end
    end
  end

protected
  
  def get_content(url)
    begin
      puts "getting : " + url if @verbose
      uri = URI.parse(url)
      return uri.read
    rescue
      return nil
    end
  end
  
  def extract(html)
    opt = {:decay_factor=>0.75} # optional settings
    extractor = ExtractContent::Extractor.new(opt)

    body, title = extractor.analyse(html) # analyse
    "#{title}\n\n#{body}"
  end
  
  def error_recovery(comment)
    puts "fail to get it. count++" if @verbose
    comment.tried_times += 1
    unless comment.tried_times < @@maximum_retry
      comment.tried_times = @@can_not_get_refernce_content_counter
      comment.foreign_content = "参照先コンテンツの取得を規定回数試みましたが、ムリっぽいので諦めました。URL確認お願いします。"
    end
    comment.save
  end
  
end
