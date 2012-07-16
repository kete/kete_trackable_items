class TrackingListsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers
  include KeteTrackableItems::ListManagementControllers

  before_filter :set_repository
  before_filter :set_tracking_list, :except => [:index, :create]

  def index
    @tracking_lists = TrackingList.all
  end

  def show
    @download_modal = params[:download_modal].present? ? params[:download_modal].param_to_obj_equiv : false

    unless params[:format] == 'xls'
      @possible_events = @tracking_list.current_state.events.keys.collect(&:to_s).sort

      # we don't want cancel to take a prominent position
      # take it out of current position and add it at end
      if @possible_events.include?('cancel')
        @possible_events.delete('cancel')
        @possible_events << 'cancel'
      end
    end

    if params[:format] == 'xls'
      @tracked_items = @tracking_list.tracked_items
    else
      set_page_variables
      
      @tracked_items = @tracking_list.tracked_items.paginate(@page_options)

      set_results_variables(@tracked_items)
    end

    # we want to gather our trackable_items in as few queries as possible
    types_and_ids = @tracked_items.inject(Hash.new) do |result, tracked_item|
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

    @tracked_item_trackable_item_pairs = @tracked_items.inject(Array.new) do |result, tracked_item|
      trackable_item = trackable_items_by_type[tracked_item.trackable_item_type].select do |item|
        item.id == tracked_item.trackable_item_id
      end.first

      result << [tracked_item, trackable_item]
      result
    end

    # xls support as outlined in http://www.arydjmal.com/blog/export-to-excel-in-rails-2
    respond_to do |format|
      format.html # index.html.erb
      format.xls { render :layout => false } if params[:format] == 'xls' # blog post noted that otherwise always interpretted as xls
    end
  end

  # unused at this point
  def new
  end

  def create
    @tracking_list = @repository.tracking_lists.build(params[:tracking_list])

    if @tracking_list.save
      redirect_to repository_tracking_list_url(:id => @tracking_list,
                                               :repository_id => @repository)
    end
  end

  def edit
    set_matching_trackable_items
    set_session_for_matching_trackable_items
  end

  # update tracked_items (i.e. add them based on a search)
  # or run state change
  def update
    url = repository_tracking_list_url(:id => @tracking_list,
                                       :repository_id => @repository)
    if params[:event]
      event = params[:event]
      case event
      when 'allocate'
        # allocating means we need to choose shelf location before proceeding
        options = { :tracking_list => @tracking_list }
        options[:urlified_name] = @site_basket.urlified_name if @current_basket.repositories.count < 1

        url = new_trackable_item_shelf_location_url(options)
        @successful = true
      when 'loan'
        # we need to collect information for a new or existing on_loan_organization
        options = { :tracking_list => @tracking_list }
        options[:urlified_name] = @site_basket.urlified_name if @current_basket.repositories.count < 1

        url = new_on_loan_organization_url(options)
        @successful = true
      else
        # otherwise, send the event as a method
        # to the tracking list
        original_state = @tracking_list.current_state
        @tracking_list.send(event + '!')
        @successful = @tracking_list.current_state != original_state
        @state_change_failed = !@successful
        url = repository_url(:id => @tracking_list,
                             :repository_id => @repository,
                             :download_modal => true)
      end
    else
      # to handle large amount of matches that span paginated pages of results
      # we use ids in session to create tracked_items
      matching_class = session[:matching_class]
      matching_results_ids = session[:matching_results_ids]
      values = matching_results_ids.inject(Array.new) do |value, matching_id|
        value << TrackedItem.new(:trackable_item_type => matching_class,
                                 :trackable_item_id => matching_id,
                                 :tracking_list_id => @tracking_list.id)
        value
      end

      @successful = TrackedItem.import(values)
    end
    
    if @successful || @state_change_failed
      clear_session_variables_for_list_building

      flash[:notice] = t('tracking_lists.update.state_change_failed', :event_transition => params[:event].humanize) if @state_change_failed

      redirect_to url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @tracking_list.destroy
    redirect_to repository_url(:id => @repository)
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end

  def set_tracking_list
    @tracking_list = @repository.tracking_lists.find(params[:id])
  end
end
