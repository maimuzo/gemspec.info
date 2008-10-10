# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #
  # for view and controler
  #
  def logged_in?
    session[:user_id]
  end

  def current_user
    @current_user ||= User.find(session[:user_id])
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
  
  def show_path_for_gemcast(gemcast)
    "/rubygems/#{gemcast.rubygem.to_param}/gemcast/#{gemcast.id.to_s}".untaint
  end


  def show_path_for_unchiku(unchiku)
    "/rubygems/#{unchiku.rubygem.to_param}/unchiku/#{unchiku.id.to_s}".untaint
  end
  
  def gender_value(sex)
    if sex == 0
      "男性"
    else
      "女性"
    end
  end
end
