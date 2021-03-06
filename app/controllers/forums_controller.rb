class ForumsController < ApplicationController
  
  before_filter :authenticate_person!, :setup

  def index
    @forums = Forum.all
    if @forums.length == 1
      redirect_to forum_url(@forums.first) and return
    end
  end

  def show
    @forum = Forum.find(params[:id])
    @topics = @forum.topics.paginate(:page => params[:page],
                                     :order => "updated_at DESC")

    respond_to do |format|
      format.html
      format.atom
    end
  end

  private
  
    def setup
      @body = "forum"
    end
end
