class ShelfLocationsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  before_filter :set_repository
  before_filter :set_shelf_location, :except => [:index, :create, :new]

  def index
  end

  def show
  end

  def new
    @shelf_location = @repository.shelf_locations.new
  end

  def edit
  end

  def create
    @shelf_location = @repository.shelf_locations.build(params[:shelf_location])

    if @shelf_location.save
      redirect_to repository_shelf_location_url(:id => @shelf_location,
                                                :repository_id => @repository)
    else
      render :action => 'new'
    end
  end

  def update
    if @shelf_location.update_attributes(params[:shelf_location])
      redirect_to repository_shelf_location_url(:id => @shelf_location,
                                                :repository_id => @repository)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @shelf_location.destroy

    redirect_to repository_url(:id => @repository)
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end

  def set_shelf_location
    @shelf_location = @repository.shelf_locations.find(params[:id])
  end
end
