class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @gems = Rubygem.find_tagged_with(@tag.name)

  end

end
