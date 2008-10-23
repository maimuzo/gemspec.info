# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #
  # for view and controler
  #
  def logged_in?
    session[:user_id]
  end

  def current_user
    if logged_in?
      return @current_user ||= User.find(session[:user_id])
    else
      return nil
    end
  end
  
  #
  # for view
  #

  def clone_sites
    CloneSite.find(:all)
  end
  
  # for left bar
  def general_ranks
    GeneralPoint.find(:all, :order => "point DESC", :limit => 20)
  end
  
  def tags_for_search
    tags = Tag.find(:all)
    tags.unshift(Tag.new({:name => "選択してください"}))
  end
    
  def tag_string_or_none(rubygem)
    if rubygem.tags.size == 0
      "(まだタグは付いていません。付けてみてください)"
    else
      rubygem.tag_list
    end
  end
  
  def plus_minus_total(base)
    (base.result_of_rating[:plus] + "/" + base.result_of_rating[:minus] + " " + base.result_of_rating[:total])
  end
    
  def plus_minus_total_for_tag(base)
    ('的確:' + base.result_of_rating[:plus] + "/ そうかな?:" + base.result_of_rating[:minus] + " " + base.result_of_rating[:total])
  end

  def gender_value(sex)
    if sex == 0
      "男性"
    else
      "女性"
    end
  end
  
  def chose_rate_links(target, user, plus_url, minus_url, reset_url = '')
    base_chose_rate_links(target, user, '＋評価', plus_url, '−評価', minus_url, '評価取消', reset_url)
  end
  
  def chose_rate_links_and_go_parent_page(target, user, plus_url, minus_url, reset_url = '')
    base_chose_rate_links(target, user, '＋評価して戻る', plus_url, '−評価して戻る', minus_url, '評価取消して戻る', reset_url)
  end
  
  def chose_rate_links_for_tag(target, user, plus_url, minus_url, reset_url = '')
    base_chose_rate_links(target, user, '的確', plus_url, 'そうかな?', minus_url, '評価取消', reset_url)
  end
  
  def base_chose_rate_links(target, user, plus_message, plus_url, minus_message, minus_url, reset_message, reset_url = '')
    link_string = ""
    return link_string if user.nil?
    if target.rated_by?(user)
      rating = what_did_user_rate?(target, user)
      logger.debug "old rating value is : " + rating.inspect
      if 0 < rating
        # user reted "plus"
        link_string << link_to(reset_message, reset_url, {:method => :post, :title => "あなたは現在＋評価していますが、これを取り消します"}) + ' '
        link_string << link_to(minus_message, minus_url, {:method => :post, :title => "あなたは現在＋評価していますが、−評価に変更します"})
      else
        # user reted "minus"
        link_string << link_to(plus_message, plus_url, {:method => :post, :title => "あなたは現在−評価していますが、＋評価に変更します"}) + ' '
        link_string << link_to(reset_message, reset_url, {:method => :post, :title => "あなたは現在−評価していますが、これを取り消します"})
      end
    else
      # user don't still rate
      link_string << link_to(plus_message, plus_url, {:method => :post, :title => "−評価します。あなたはまだ評価していません"}) + ' '
      link_string << link_to(minus_message, minus_url, {:method => :post, :title => "−評価します。あなたはまだ評価していません"})      
    end 
    link_string.untaint
  end
  
  # examine a rated rating by the user
  def what_did_user_rate?(target, user)
    case target.class.to_s
    when 'Obstacle' then class_name = 'Comment'
    when 'Unchiku' then class_name = 'Comment'
    when 'Gemcast' then class_name = 'Comment'
    when 'What' then class_name = 'Abstract'
    when 'Strength' then class_name = 'Abstract'
    when 'Weakness' then class_name = 'Abstract'
    else
      class_name = target.class.to_s
    end
    cond = ["rater_id = :rater_id and rated_id = :rated_id and rated_type = :rated_type",
      {:rater_id => user.id, :rated_id => target.id, :rated_type => class_name}]
    rated = Rating.find(:first, :conditions => cond)
    if rated.nil?
      return nil
    else
      return rated.rating
    end
  end
  
  # added class="niceforms inline-form" to the form
  def niceforms_button_to(name, options = {}, html_options = {})
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))

    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
     method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end

    form_method = method.to_s == 'get' ? 'get' : 'post'

    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
     request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end

    if confirm = html_options.delete("confirm")
     html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
    end

    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url

    html_options.merge!("type" => "submit", "value" => name)

    "<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to niceforms inline-form\"><div>" +
     method_tag + tag("input", html_options) + request_token_tag + "</div></form>"
  end
    
  def site_link(detail)
    if detail.homepage.blank?
      return "NO DATA"
    else
      return link_to('公式サイト', strip_tags(detail.homepage), {:target => "_blank"}).untaint
    end
  end
  
  def project_link(detail)
    link_string = ""
    unless detail.project_name.blank?
      link_string <<  link_to('home', "http://" + strip_tags(detail.project_name) + ".rubyforge.org/", {:target => "_blank"})
      link_string << " / "
      link_string <<  link_to('project', "http://rubyforge.org/projects/" + strip_tags(detail.project_name) + "/", {:target => "_blank"})
    end
    link_string.untaint
  end
  
  def depend_link(depend)
    h(depend.depgem + "[" + depend.depversion + "]")
  end
  
  def formated_date_with_check(date)
    formated = date.strftime("%Y/%m/%d")
    formated = "NO DATA" if "1900/01/01" == formated
    formated
  end
  
  def check_install_message(message)
    if message.blank?
      return "NO DATA"
    else
      return simple_format(h(message))
    end
  end
  
  def already_inputed_tag(tag)
    label = h(tag.name) + "(" + tag.taggings_count.to_s + ")"
    link_to(label, "javascript:return false;", {:class => "tag-example", :tag => h(tag.name), :onclick => "add_tag_name($j(this).attr('tag'));"})
  end
  
  def make_unchiku_trackback_url(gem)
    unchiku_trackback_url({:rubygem_id => gem.to_param, :user_key => current_user.user_key})
  end

  def make_obstacle_trackback_url(version)
    obstacle_trackback_url({:version_id => version.to_param, :user_key => current_user.user_key})
  end

  def nico_link(gemcast)
    ('<iframe width="312" height="176" src="http://ext.nicovideo.jp/thumb/' + h(gemcast.nico_content_key) + '" scrolling="no" style="border:solid 1px #CCC;" frameborder="0"><a href="http://www.nicovideo.jp/watch/' + h(gemcast.nico_content_key) + '">' + h(gemcast.title) + '</a></iframe>').untaint
  end

end
