module KeteTrackableItems
  module PaginateSetUp
    def per_page_default
      10
    end

    def set_page_variables
      @page = params[:page].to_i
      @page = 1 if @page == 0
      @per_page = params[:per_page].to_i
      @per_page = per_page_default if @per_page == 0

      @page_options = { :page => @page, :per_page => @per_page }
    end

    def set_results_variables(collection)
      @start_record = collection.offset + 1
      @end_record = @per_page * @page
      @end_record = collection.total_entries if collection.total_entries < @end_record
    end
  end
end
