class Admin::PeopleController < ApplicationController

  before_filter :authenticate_person!, :admin_required

  def index
    @people = Person.all.paginate(:page => params[:page], :order => :name)
  end

  def update
    @person = Person.find(params[:id])
    if current_person?(@person)
      flash[:error] = "Action failed."
    else
      @person.toggle!(params[:task])
      flash[:success] = "#{CGI.escapeHTML @person.name} updated."
    end
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
end