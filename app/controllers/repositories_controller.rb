class RepositoriesController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers

  before_filter :get_repository, :except => [:new, :create, :index]

  READABLE_ACTIONS = [:show, :index]

  permit "site_admin or admin of :site_basket", :except => READABLE_ACTIONS

  permit "site_admin or admin of :site_basket or moderator of :current_basket or admin of :current_basket", :only => READABLE_ACTIONS

  def index
    @repositories = appropriate_repositories_for_basket

    params[:trackable_type_param_key] = 'topics' unless params[:trackable_type_param_key]

    if params[:within].blank?
      if @current_basket == @site_basket
        params[:within] = 'all'
      else
        params[:within] = @current_basket.id
      end
    end

    if @current_basket != @site_basket && params[:within] != @current_basket.id 
      raise "You cannot specify a basket other than your own."
    end

    params[:state] = 'on_shelf' unless params[:state]
    @state = params[:state]

    set_matching_trackable_items

    @matching_class = session[:matching_class]
    klass = @matching_class.constantize
    @trackable_item_state_names = klass.workflow_spec.state_names

    @trackable_items_counts = @trackable_item_state_names.inject(Hash.new) do |counts, state|
      if params[:within] != 'all'
        if params[:within] == 'central'
          counts[state] = klass.workflow_in(state).not_in_these_baskets(repository_basket_ids_not_in_site).count
        else
          counts[state] = klass.workflow_in(state).in_basket(params[:within]).count
        end

      else
        counts[state] = klass.workflow_in(state).count
      end

      counts
    end
    @trackable_items_counts[:all] = klass.count

    set_results_variables(@matching_trackable_items)
  end

  def show
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
