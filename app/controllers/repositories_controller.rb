class RepositoriesController < ApplicationController
  
  def index
    @repositories = Repository.all

    respond_to do |format|
      format.html
    end
  end

  def show
    @repository = Repository.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def new
    @repository = Repository.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def create
    @repository = Repository.new(params[:repository])

    respond_to do |format|
      if @repository.save
        format.html { redirect_to @repository }
      else
        render :action => 'new'
      end
    end
  end

  def update
    @repository = Repository.find(params[:id])

    if @repository.update_attributes(params[:repository])
      render :action => 'index'
       # redirect_to :controller => 'repositories', :action => 'edit', :id => @repository.id
       #
    else
      render :action => 'edit'
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url }
    end
  end
end
