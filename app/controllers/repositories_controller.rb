class RepositoriesController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable
  
  before_filter :get_repository, :except => [:new, :create, :index]

  READABLE_ACTIONS = [:show, :index]

  permit "site_admin or admin of :site_basket", :except => READABLE_ACTIONS

  permit "site_admin or admin of :site_basket or moderator of :current_basket or admin of :current_basket", :only => READABLE_ACTIONS

  def index
    @repositories = appropriate_repositories_for_basket
  end

  def show
  end

  def new
    @repository = Repository.new
  end

  def edit
  end

  def create
    # a repository belongs to whatever basket it was created in
    params[:repository][:basket_id] = @current_basket.id

    @repository = Repository.new(params[:repository])

    if @repository.save
      redirect_to repository_url(:id => @repository)
    else
      render :action => 'new'
    end
  end

  def update
    if @repository.update_attributes(params[:repository])
      redirect_to repository_url(:id => @repository)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @repository.destroy

    redirect_to repositories_url
  end

  private
  
  def get_repository
    begin
      @repository = @current_basket.repositories.find(params[:id])
    rescue
      @repository = Repository.find(params[:id])

      if @current_basket != @repository.basket
        redirect_to url_for(:urlified_name => @site_basket.urlified_name,
                            :action => params[:action],
                            :id => params[:id])
      end
    end
  end
end
