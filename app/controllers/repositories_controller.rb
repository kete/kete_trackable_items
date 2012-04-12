# scaffold only - needs fleshing out
class RepositoriesController < ApplicationController
  
  # GET /repositories
  def index
    @repositories = Repository.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /repositories/1
  def show
    @repository = Repository.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /repositories/new
  def new
    @repository = Repository.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /repositories/1/edit
  def edit
    @repository = Repository.find(params[:id])
  end

  # POST /repositories
  def create
    @repository = Repository.new(params[:repository])

    respond_to do |format|
      if @repository.save
        render :action => 'index'
      else
        render :action => 'new'
      end
    end
  end

  # PUT /repositories/1
  def update
    @repository = Repository.find(params[:id])

    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to @repository }
      else
        render :action => 'edit'
      end
    end
  end

  # DELETE /repositories/1
  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url }
    end
  end
end
