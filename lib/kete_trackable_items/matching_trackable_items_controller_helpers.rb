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

        always_scopes = Kete.trackable_item_scopes[type_key]['search_scopes']['always_within_scopes'].keys

        # a trackable_item has to be allocated a shelf before it can be added to a tracking_list
        # NOTE: using tracking_lists to allocate shelf_location in bulk for a given set of items
        # dropping this scope constraint, but leaving for reference
        # in case it is useful in future
        # always_scopes << 'with_state_on_shelf' if params[:controller] == 'tracking_lists'
        
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

        @matching_trackable_items = @matching_trackable_items.paginate(@page_options)

        set_results_variables(@matching_trackable_items)

        @matching_trackable_items_only_ids = relevent_scopes.inject(klass) do |model_class, relevent_scope|
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
      if @matching_trackable_items_only_ids.any?
        session[:matching_results_ids] = @matching_trackable_items_only_ids
      else
        session[:matching_results_ids] = Array.new
      end
    end
  end
end
