module KeteTrackableItems
  # actions, etc. to add or delete items from tracking_list
  # or shelf_location being built up
  module ListManagementControllers
    # assumes matching_results_ids in the session
    # drops a given remove_id from the session variable
    def remove_from_list
      begin
        matching_results_ids = session[:matching_results_ids]
        matching_results_ids.delete(params[:remove_id].to_i)
        session[:matching_results_ids] = matching_results_ids
        render :nothing => true
      rescue
        render :nothing => true, :status => 500
      end
    end

    # assumes matching_results_ids in the session
    # puts back a given restore_id in the session variable
    def restore_to_list
      begin
        matching_results_ids = session[:matching_results_ids]
        session[:matching_results_ids] = matching_results_ids << params[:restore_id].to_i
        render :nothing => true
      rescue
        render :nothing => true, :status => 500
      end
    end

    def clear_session_variables_for_list_building
      session[:matching_class] = nil if session[:matching_class].present?
      session[:matching_results_ids] = nil if session[:matching_results_ids].present?
    end
  end
end
