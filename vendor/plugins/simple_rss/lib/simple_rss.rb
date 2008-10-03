module SimpleRss

  def render_rss_feed(resources, options = {})
    render :text => rss_feed(resources, options), :content_type => Mime::RSS
  end

  def rss_feed(articles, options = {})
    xml = Builder::XmlMarkup.new(:indent => 2)

    feed = options[:feed] || {}
    feed[:title] ||= "새로운 블로그"
    feed[:url] ||= "http://blog.example.com/"
    feed[:item_url_prefix] ||= ""

    item = options[:item] || {}
    item[:title] ||= :title
    item[:description] ||= :description
    item[:pub_date] ||= :created_at
    item[:permalink] ||= :permalink
    
    xml.instruct!
    xml.rss({:version => 2.0}) do
      xml.channel do
        xml.title(feed[:title])
        xml.link(feed[:url])
        xml.description(feed[:description]) if feed[:description]
        xml.language("ko")
        xml.ttl("40")

        for article in articles
          xml.item do
            xml.title(article.send(item[:title]))
            xml.description(article.send(item[:description]))
            xml.pubDate(article.send(item[:pub_date]).to_s(:rfc822))
            xml.guid(feed[:url] + feed[:item_url_prefix] + article.send(item[:permalink]).to_s)
            xml.link(feed[:url] + feed[:item_url_prefix] + article.send(item[:permalink]).to_s)
          end
        end
      end
    end
  end
end
