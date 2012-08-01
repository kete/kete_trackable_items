require 'kete_trackable_items/paginate_set_up'

module KeteTrackableItems
  module MatchingTrackableItemsControllerHelpers
    unless included_modules.include? PaginateSetUp
      def self.included(base)
        base.send(:include, PaginateSetUp)
      end
    end

    def set_matching_trackable_items
      set_page_variables

      # do we have a search for trackable_items to add?
      if params[:trackable_type_param_key].present?
        # compose our find based on input and Kete.trackable_item_scopes
        type_key_plural = params[:trackable_type_param_key]

        type_key = type_key_plural.singularize
        class_name = type_key.camelize
        session[:matching_class] = class_name
        klass = class_name.constantize

        skip_already_associated_scope = Array.new
        existing_ids = Array.new
        in_state_scope = Array.new

        case params[:controller]
        when 'shelf_locations'
          existing_ids = @shelf_location.trackable_item_shelf_locations.find(:all,
                                                                             :select => 'trackable_item_id',
                                                                             :conditions => { :trackable_item_type => class_name }).collect(&:trackable_item_id)
        when 'tracking_lists'
          existing_ids = @tracking_list.tracked_items.find(:all,
                                                           :select => 'trackable_item_id',
                                                           :conditions => { :trackable_item_type => class_name }).collect(&:trackable_item_id)
        when 'repositories'
          in_state_scope << ['workflow_in', params[:state]] if params[:state]
        else
          raise "Controller not currently handled."
        end

        skip_already_associated_scope << ['not_one_of_these', existing_ids] if existing_ids.any?

        # if we are in a basket other than site
        # limit our results to only within that basket
        #
        # when doing location tracking from site basket (i.e. all repositories view)
        # we may be handling a repository that is actually associated with a specific basket of items
        # if so, use the repository's basket to limit our results
        #
        # if the repository's basket is site, we need to make sure to not include results
        # from baskets that have their own repository, rather than being in the site wide catch-all
        #
        # case where within basket is specified as either all (i.e. don't limit, for site wide reporting)
        # or central (everything not in another basket other than site)
        # or where basket is explicitly specified
        basket_scope_pair = Array.new
        if params[:within].present?
          if params[:within] != 'all'
            if params[:within] == 'central'
              basket_scope_pair << ['not_in_these_baskets', repository_basket_ids_not_in_site]
            else
              basket_scope_pair << ['in_basket', params[:within]]
            end
          end
        else
          if @current_basket != @site_basket
            basket_scope_pair << ['in_basket', @current_basket.id]
          else
            if @repository.basket != @site_basket
              basket_scope_pair << ['in_basket', @repository.basket_id]
            else
              basket_scope_pair << ['not_in_these_baskets', repository_basket_ids_not_in_site]
            end
          end
        end

        always_scopes = Kete.trackable_item_scopes[type_key]['search_scopes']['always_within_scopes'].keys

        # a trackable_item has to be allocated a shelf before it can be added to a tracking_list
        # NOTE: using tracking_lists to allocate shelf_location in bulk for a given set of items
        # dropping this scope constraint, but leaving for reference
        # in case it is useful in future
        # always_scopes << 'with_state_on_shelf' if params[:controller] == 'tracking_lists'
        
        scope_value_pairs = Array.new
        
        if params[type_key_plural].present?
          scope_value_pairs = params[type_key_plural].select { |k, v| v.present? }
        end
        
        @relevent_scopes = basket_scope_pair +
          in_state_scope +
          always_scopes +
          scope_value_pairs +
          skip_already_associated_scope

        @matching_trackable_items = @relevent_scopes.inject(klass) do |model_class, relevent_scope|
          if relevent_scope.is_a?(Array)
            model_class.send(relevent_scope.first, relevent_scope.last)
          else
            model_class.send(relevent_scope)
          end
        end

        @matching_trackable_items = @matching_trackable_items.paginate(@page_options)

        set_results_variables(@matching_trackable_items)

        @matching_trackable_items_only_ids = @relevent_scopes.inject(klass) do |model_class, relevent_scope|
          if relevent_scope.is_a?(Array)
            model_class.send(relevent_scope.first, relevent_scope.last)
          else
            model_class.send(relevent_scope)
          end
        end

        @matching_trackable_items_only_ids = @matching_trackable_items_only_ids.find(:all, :select => 'id').collect(&:id)
      end
    end

    def set_session_for_matching_trackable_items
      if @matching_trackable_items_only_ids.present?
        session[:matching_results_ids] = @matching_trackable_items_only_ids
      else
        session[:matching_results_ids] = Array.new
      end
    end

    def repository_basket_ids_not_in_site
      @repository_basket_ids ||= Repository.find(:all,
                                                 :select => 'DISTINCT(basket_id)',
                                                 :conditions => "basket_id != #{@site_basket.id}").collect(&:basket_id)
    end
  end
end
