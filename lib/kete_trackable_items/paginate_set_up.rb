module KeteTrackableItems
  module PaginateSetUp
    PER_PAGE = 10

    def set_page_variables
      @page = params[:page].to_i
      @page = 1 if @page == 0
      @per_page = params[:per_page].to_i
      @per_page = PER_PAGE if @per_page == 0

      @page_options = { :page => @page, :per_page => @per_page }
    end

    def set_results_variables(collection)
      @start_record = collection.offset + 1
      @end_record = @per_page * @page
      @end_record = collection.total_entries if collection.total_entries < @end_record
    end
  end
end
