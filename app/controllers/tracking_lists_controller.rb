class TrackingListsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  before_filter :set_repository
  before_filter :set_tracking_list, :except => [:index, :create]

  def index
    @tracking_lists = TrackingList.all
  end

  def show
    @possible_events = @tracking_list.current_state.events.keys.collect(&:to_s).sort
  end

  # unused at this point
  def new
    set_matching_trackable_items

    build_tracked_items_for_matching_trackable_items
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

    build_tracked_items_for_matching_trackable_items
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

  def set_matching_trackable_items
    # do we have a search for trackable_items to add?
    if params[:trackable_type_param_key].present?
      # compose our find based on input and Kete.trackable_item_scopes
      type_key_plural = params[:trackable_type_param_key]

      type_key = type_key_plural.singularize
      class_name = type_key.camelize
      klass = class_name.constantize

      always_scopes = Kete.trackable_item_scopes[type_key]['search_scopes']['always_within_scopes'].keys

      # a trackable_item has to be allocated a shelf before it can be added to a tracking_list
      always_scopes << 'with_state_on_shelf'

      scope_value_pairs = params[type_key_plural].select { |k, v| v.present? }
      
      scope_value_pairs << ['in_basket', @current_basket.id] unless @current_basket == @site_basket

      relevent_scopes = always_scopes + scope_value_pairs

      @matching_trackable_items = relevent_scopes.inject(klass) do |model_class, relevent_scope|
        if relevent_scope.is_a?(Array)
          model_class.send(relevent_scope.first, relevent_scope.last)
        else
          model_class.send(relevent_scope)
        end
      end
    end
  end

  def build_tracked_items_for_matching_trackable_items
    if @matching_trackable_items.present?
      @matching_trackable_items.each do |trackable_item|
        @tracking_list.tracked_items.build(:trackable_item => trackable_item)
      end
    end
  end
end
