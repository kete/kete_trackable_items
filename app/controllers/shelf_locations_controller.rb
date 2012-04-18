class ShelfLocationsController < ApplicationController

  def index
    @shelf_locations = ShelfLocation.all

    respond_to do |format|
      format.html 
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
    @repo = @shelf_location.repository
  end

  def create
    @shelf_location = ShelfLocation.new(params[:shelf_location])

    if @shelf_location.save

      redirect_to url_for_repository( @shelf_location.repository_id)
    else
      render :action => 'new'
    end
  end

  def update


    @shelf_location = ShelfLocation.find(params[:id])

    if @shelf_location.update_attributes(params[:shelf_location])
      redirect_to url_for_repository( @shelf_location.repository_id)
    else
      render :action => 'edit'
    end
  end

  def destroy

#Rails.logger.debug("what is ID: " + params[:id])

    @shelf_location = ShelfLocation.find(params[:id])
    repo = @shelf_location.repository_id
    @shelf_location.destroy

    respond_to do |format|
      format.html { redirect_to url_for_repository repo }
    end
  end
end
