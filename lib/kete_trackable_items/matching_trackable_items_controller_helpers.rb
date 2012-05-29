module KeteTrackableItems
  module MatchingTrackableItemsControllerHelpers
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
        always_scopes << 'with_state_on_shelf' if params[:controller] == 'tracking_lists'
        
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

    def build_items_for_matching_trackable_items_for(target, collection_name)
      if @matching_trackable_items.present?
        @matching_trackable_items.each do |trackable_item|
          target.send(collection_name).build(:trackable_item => trackable_item)
        end
      end
    end
  end
end
