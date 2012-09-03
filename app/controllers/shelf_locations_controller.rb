class ShelfLocationsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers
  include KeteTrackableItems::ListManagementControllers

  before_filter :set_repository
  before_filter :set_shelf_location, :except => [:index, :create, :new]

  permit "site_admin or admin of :site_basket or admin of :current_basket"

  def index
    if params[:code_pattern].present?
      @code_pattern = params[:code_pattern]
      pattern_for_sql = @code_pattern.downcase + '%'
      @shelf_locations = @repository.shelf_locations.find(:all,
                                                          :conditions => ["LOWER(code) like :pattern_for_sql",
                                                                          { :pattern_for_sql => pattern_for_sql }])
    else
      params[:per_page] = 100 unless params[:per_page]
      set_page_variables

      @state = params[:shelf_state].present? ? params[:shelf_state] : 'all'
      if @state != 'all'
        @page_options[:conditions] = ["workflow_state = ?", @state]
      end
      
      @shelf_locations = @repository.shelf_locations.paginate(@page_options)
      
      set_results_variables(@shelf_locations)
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

    set_page_variables

    @trackable_item_shelf_locations = @shelf_location.trackable_item_shelf_locations.paginate(@page_options)

    set_results_variables(@trackable_item_shelf_locations)

    # we want to gather our trackable_items in as few queries as possible
    # do not want to use @shelf_location.trackable_items, as that would be all items for a shelf location
    # which could be very large
    # instead, just want to grab trackable_items for this page's trackable_item_shelf_locations
    types_and_ids = @trackable_item_shelf_locations.inject(Hash.new) do |result, tracked_item|
      type_key = tracked_item.trackable_item_type
      item_id = tracked_item.trackable_item_id

      values = result[type_key] || Array.new
      values << item_id

      result[type_key] = values
      result
    end

    trackable_items_by_type = Hash.new
    types_and_ids.each do |k,v|
      trackable_items_by_type[k] = k.constantize.find(v)
    end

    @trackable_item_shelf_location_trackable_item_pairs = @trackable_item_shelf_locations.inject(Array.new) do |result, trackable_item_shelf_location|
      trackable_item = trackable_items_by_type[trackable_item_shelf_location.trackable_item_type].select do |item|
        item.id == trackable_item_shelf_location.trackable_item_id
      end.first

      result << [trackable_item_shelf_location, trackable_item]
      result
    end
  end

  def new
    @shelf_location = @repository.shelf_locations.new
  end

  def edit
    set_matching_trackable_items

    set_session_for_matching_trackable_items
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

      # to handle large amount of matches that span paginated pages of results
      # we use ids in session to create trackable_item_shelf_locations
      matching_class = session[:matching_class]
      matching_results_ids = session[:matching_results_ids]
      values = matching_results_ids.inject(Array.new) do |value, matching_id|
        value << TrackableItemShelfLocation.new(:trackable_item_type => matching_class,
                                                :trackable_item_id => matching_id,
                                                :shelf_location_id => @shelf_location.id)
        value
      end

      if values.present?
        @successful = TrackableItemShelfLocation.import(values)

        if @successful
          @shelf_location.new_allocation
          matching_class.constantize.find(matching_results_ids).each do |trackable_item|
            trackable_item.new_allocation
          end
        end
      end
    end
    
    if @successful || @state_change_failed
      clear_session_variables_for_list_building

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
