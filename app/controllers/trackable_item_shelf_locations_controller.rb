class TrackableItemShelfLocationsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  def new
    if params[:trackable_item].present?
      @trackable_item = params[:trackable_item][:type].constantize.find(params[:trackable_item][:id])
    end

    @repositories = appropriate_repositories_for_basket

    @trackable_item_shelf_location = @trackable_item ? @trackable_item.trackable_item_shelf_locations.build : TrackableItemShelfLocation.new
  end
  
  def create
  end

  # ajax autocomplete target that will return json for shelf_locations options
  # that are within a repository
  def shelf_locations_for_repository_as_options
  end
end
