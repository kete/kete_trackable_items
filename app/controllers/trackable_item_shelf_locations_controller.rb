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
    repository_id = params[:trackable_item_shelf_location].delete(:repository_id)
    code = params[:trackable_item_shelf_location].delete(:code)

    if repository_id.present?
      @repository = Repository.find(repository_id)
      @repositories = [@repository]
    end

    if @repository.present? && code.present?
      @shelf_location = @repository.shelf_locations.find_by_code(code)
      params[:trackable_item_shelf_location][:shelf_location_id] = @shelf_location ? @shelf_location.id : nil
    end

    @trackable_item_shelf_location = TrackableItemShelfLocation.new(params[:trackable_item_shelf_location])
    @trackable_item = @trackable_item_shelf_location.trackable_item

    if @trackable_item_shelf_location.save
      redirect_to url_for_dc_identifier(@trackable_item)
    else
      render :action => 'new'
    end
  end

  def update
    @trackable_item_shelf_location = TrackableItemShelfLocation.find(params[:id])

    if params[:event]
      original_state = @trackable_item_shelf_location.current_state
      event_method = params[:event] + '!'
      @trackable_item_shelf_location.send(event_method)
      @successful = @trackable_item_shelf_location.current_state != original_state
      @state_change_failed = @succesful
    else
      @successful = @trackable_item_shelf_location.update_attributes(params[:shelf_location])
    end
    
    if @successful || @state_change_failed
      flash[:notice] = t('shelf_locations.update.state_change_failed', :event_transition => params[:event].humanize) if @state_change_failed

      url = repository_shelf_location_url(:id => @trackable_item_shelf_location.shelf_location,
                                          :repository_id => @trackable_item_shelf_location.shelf_location.repository)
      redirect_to url
    else
      render :action => 'edit'
    end
  end
  
end
