class UnchikusController < ApplicationController

  def show
    @gem = Rubygem.find(params[:rubygem_id])
    @title = "add tag for " + @gem.name
    if params[:version]
      @version = @gem.versions.find(params[:version])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles

    @comment = @gem.unchikus.find(params[:id])
  end

  def new
    @gem = Rubygem.find(params[:rubygem_id])
    @title = "add tag for " + @gem.name
    if params[:version]
      @version = @gem.versions.find(params[:version])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles

    @comment = @gem.unchikus.build
  end

  def edit
  end

end
