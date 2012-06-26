class ShelfLocationsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers

  before_filter :set_repository
  before_filter :set_shelf_location, :except => [:index, :create, :new]

  def index
    if params[:code_pattern].present?
      @code_pattern = params[:code_pattern]
      pattern_for_sql = @code_pattern.downcase + '%'
      @shelf_locations = @repository.shelf_locations.find(:all,
                                                          :conditions => ["LOWER(code) like :pattern_for_sql",
                                                                          { :pattern_for_sql => pattern_for_sql }])
    else
      @shelf_locations = @repository.shelf_locations      
    end

    respond_to do |format|
      format.html
      format.json  { render :json => @shelf_locations }
      format.js do
        render :inline => "<%= auto_complete_result(@shelf_locations, :code) %>"
      end
    end
  end

  def show
    @possible_events = @shelf_location.current_state.events.keys.collect(&:to_s).sort

    # this is always done through creation of trackable_item_shelf_location
    @possible_events -= ['allocate']

    # not available through this interface
    @possible_events -= ['deallocate']
  end

  def new
    @shelf_location = @repository.shelf_locations.new
  end

  def edit
    set_matching_trackable_items

    build_items_for_matching_trackable_items_for(@shelf_location, :trackable_item_shelf_locations)
  end

  def create
    @shelf_location = @repository.shelf_locations.build(params[:shelf_location])

    if @shelf_location.save
      # redirect to listing of shelf locations on repository index
      # instead of show page
      redirect_to repository_url(:id => @repository)
    else
      render :action => 'new'
    end
  end

  def update
    if params[:event]
      original_state = @shelf_location.current_state
      event_method = params[:event] + '!'
      @shelf_location.send(event_method)
      @successful = @shelf_location.current_state != original_state
      @state_change_failed = @succesful
    else
      @successful = @shelf_location.update_attributes(params[:shelf_location])
    end
    
    if @successful || @state_change_failed
      flash[:notice] = t('shelf_locations.update.state_change_failed', :event_transition => params[:event].humanize) if @state_change_failed

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
