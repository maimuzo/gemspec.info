# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #
  # for view and controler
  #
  #
  def login?
    session[:user_id]
  end

  def logined_user
    User.find(session[:user_id])
  end
  
  # for left bar
  def general_ranks
    GeneralPoint.find(:all, :order => "point DESC", :limit => 20)
  end
  
  
  #
  # for view
  #
  def tag_string_or_none(rubygem)
    if rubygem.tags.size == 0
      "まだタグは付いていません。付けてみてください"
    else
      rubygem.tag_list
    end
  end
  
  # "/rubygems/#{ranking.rubygem.to_param}"
end
