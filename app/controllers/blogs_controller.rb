class BlogsController < ApplicationController

  before_filter :authenticate_person!

  def show
    @body = "blog"
    @blog = Blog.find(params[:id])
    @posts = @blog.posts.paginate(:page => params[:page])
    
    respond_to do |format|
      format.html
    end
  end
end
