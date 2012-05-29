class TrackingListsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers

  before_filter :set_repository
  before_filter :set_tracking_list, :except => [:index, :create]

  def index
    @tracking_lists = TrackingList.all
  end

  def show
    unless params[:format] == 'xls'
      @possible_events = @tracking_list.current_state.events.keys.collect(&:to_s).sort
    end

    # xls support as outlined in http://www.arydjmal.com/blog/export-to-excel-in-rails-2
    respond_to do |format|
      format.html # index.html.erb
      format.xls { render :layout => false } if params[:format] == 'xls' # blog post noted that otherwise always interpretted as xls
    end
  end

  # unused at this point
  def new
    set_matching_trackable_items

    build_items_for_matching_trackable_items_for(@tracking_list, :tracked_items)
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

    build_items_for_matching_trackable_items_for(@tracking_list, :tracked_items)
  end

  # update tracked_items (i.e. add them based on a search)
  # or run state change
  def update
    if params[:event]
      original_state = @tracking_list.current_state
      event_method = params[:event] + '!'
      @tracking_list.send(event_method)
      @successful = @tracking_list.current_state != original_state
      @state_change_failed = @succesful
    else
      @successful = @tracking_list.update_attributes(params[:tracking_list])
    end
    
    if @successful || @state_change_failed
      flash[:notice] = t('tracking_lists.update.state_change_failed', :event_transition => params[:event].humanize) if @state_change_failed

      redirect_to repository_tracking_list_url(:id => @tracking_list,
                                               :repository_id => @repository)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @tracking_list.destroy

    # TODO: may need to redirect a different place in some contexts
    redirect_to repository_tracking_lists_url(:repository_id => @repository)
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end

  def set_tracking_list
    @tracking_list = @repository.tracking_lists.find(params[:id])
  end
end
