class RepositoriesController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers

  before_filter :get_repository, :except => %i[new create index]

  READABLE_ACTIONS = %i[show index]

  permit "site_admin or admin of :site_basket", :except => READABLE_ACTIONS

  permit "site_admin or admin of :site_basket or admin of :current_basket", :only => READABLE_ACTIONS

  def index
    @repositories = appropriate_repositories_for_basket

    params[:trackable_type_param_key] = 'topics' unless params[:trackable_type_param_key]

    if params[:within].blank?
      if @current_basket == @site_basket
        params[:within] = 'central'
      else
        params[:within] = @current_basket.id
      end
    end

    if @current_basket != @site_basket &&
       params[:within].to_i != @current_basket.id
      raise "You cannot specify a basket other than your own."
    end

    params[:state] = 'unallocated' unless params[:state]
    @state = params[:state]

    set_matching_trackable_items

    klass = session[:matching_class].constantize
    @trackable_item_state_names = klass.workflow_spec.state_names - [:on_shelf]

    scopes_without_state_scope = @relevent_scopes
    scopes_without_state_scope.delete(['workflow_in', @state])

    @trackable_items_counts = Hash.new

    state_names_count = 1
    @trackable_item_state_names.each do |state|
      count_scopes_for_state = scopes_without_state_scope.inject(klass) do |model_class, relevent_scope|
        if relevent_scope.is_a?(Array)
          model_class.send(relevent_scope.first, relevent_scope.last)
        else
          model_class.send(relevent_scope)
        end
      end

      @trackable_items_counts[:all] = count_scopes_for_state.count if state_names_count == 1

      @trackable_items_counts[state] = count_scopes_for_state.workflow_in(state).count

      state_names_count += 1
    end

    set_results_variables(@matching_trackable_items)
  end

  def show
    params[:per_page] = 100 unless params[:per_page]
    set_page_variables

    @state = params[:shelf_state].present? ? params[:shelf_state] : 'all'
    if @state != 'all'
      @page_options[:conditions] = ["workflow_state = ?", @state]
    end

    @shelf_locations = @repository.shelf_locations.paginate(@page_options)

    set_results_variables(@shelf_locations)
  end

  def new
    @repository = Repository.new
  end

  def edit
  end

  def create
    # a repository belongs to whatever basket it was created in
    params[:repository][:basket_id] = @current_basket.id

    @repository = Repository.new(params[:repository])

    if @repository.save
      redirect_to repository_url(:id => @repository)
    else
      render :action => 'new'
    end
  end

  def update
    if @repository.update_attributes(params[:repository])
      redirect_to repository_url(:id => @repository)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @repository.destroy

    redirect_to repositories_url
  end

  private

  def get_repository
    begin
      @repository = @current_basket.repositories.find(params[:id])
    rescue
      @repository = Repository.find(params[:id])

      if @current_basket != @repository.basket
        redirect_to url_for(:urlified_name => @site_basket.urlified_name,
                            :action => params[:action],
                            :id => params[:id])
      end
    end
  end
end
