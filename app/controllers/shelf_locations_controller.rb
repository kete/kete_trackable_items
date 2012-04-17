class ShelfLocationsController < ApplicationController

  def index
    @shelf_locations = ShelfLocation.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @shelf_location = ShelfLocation.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def new
    @repo = Repository.find(params[:repo])

    @shelf_location = @repo.shelf_locations.new
  end

  def edit
    @shelf_location = ShelfLocation.find(params[:id])
  end

  def create
    @shelf_location = ShelfLocation.new(params[:shelf_location])

    respond_to do |format|
      if @shelf_location.save
        format.html { redirect_to repositories_path }
      else
        render :action => 'new'
      end
    end
  end

  def update
    @shelf_location = ShelfLocation.find(params[:id])

    if @shelf_location.update_attributes(params[:shelf_location])
      render :action => 'index'
      # redirect_to :controller => 'shelf_location', :action => 'edit', :id => @shelf_location.id
      #redirect_to shelf_locations_path} #, :urlified_name => @current_basket.urlified_name  }
    else
      render :action => 'edit'
    end
  end

  def destroy
    @shelf_location = ShelfLocation.find(params[:id])
    @shelf_location.destroy

    respond_to do |format|
      format.html { redirect_to repository_url(@shelf_location.repository.id,:urlified_name => @current_basket.urlified_name)}
    end
  end
end
