require 'bulk_allocation'
class TrackableItemShelfLocationsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  permit "site_admin or admin of :site_basket or admin of :current_basket"

  def new
    @repositories = appropriate_repositories_for_basket

    if params[:trackable_item].present?
      @trackable_item = params[:trackable_item][:type].constantize.find(params[:trackable_item][:id])
    elsif params[:tracking_list].present?
      @tracking_list = TrackingList.find(params[:tracking_list])
    end

    @trackable_item_shelf_location = @trackable_item.present? ? @trackable_item.trackable_item_shelf_locations.build : TrackableItemShelfLocation.new
  end

  def create
    repository_id = params[:trackable_item_shelf_location].delete(:repository_id)
    code = params[:trackable_item_shelf_location].delete(:code)
    @tracking_list = TrackingList.find(params[:tracking_list]) if params[:tracking_list]

    if repository_id.present?
      @repository = Repository.find(repository_id)
      @repositories = [@repository]
    end

    if @repository.present? && code.present?
      @shelf_location = @repository.shelf_locations.find_by_code(code)
      params[:trackable_item_shelf_location][:shelf_location_id] = @shelf_location ? @shelf_location.id : nil
    end

    if @tracking_list
      # create an trackable_item_shelf_location for each tracked_item for the tracking_list
      @tracking_list.tracked_items.each do |tracked_item|
        options = params[:trackable_item_shelf_location]
        options[:trackable_item_type] = tracked_item.trackable_item_type
        options[:trackable_item_id] = tracked_item.trackable_item_id

        previously_deactivated = options.merge(:workflow_state => "deactivated")
        @trackable_item_shelf_location = TrackableItemShelfLocation.first(:conditions => previously_deactivated)
        if @trackable_item_shelf_location
          @trackable_item_shelf_location.reactivate!
          @successful = true
        else
          @trackable_item_shelf_location = TrackableItemShelfLocation.new(options)
          @successful = @trackable_item_shelf_location.save
        end

        # stop at the point we get failure, so we only report the error on that one object
        # far from perfect solution, but hopefully very unlikely
        break unless @successful
      end
      @tracking_list.allocate! if @successful

    else
      previously_deactivated = params[:trackable_item_shelf_location].merge(:workflow_state => "deactivated")
      @trackable_item_shelf_location = TrackableItemShelfLocation.first(:conditions => previously_deactivated)

      if @trackable_item_shelf_location
        @trackable_item_shelf_location.reactivate!
        @successful = true
      else
        @trackable_item_shelf_location = TrackableItemShelfLocation.new(params[:trackable_item_shelf_location])
        @successful = @trackable_item_shelf_location.save
      end

      @trackable_item = @trackable_item_shelf_location.trackable_item
    end

    if @successful
      if @tracking_list
        redirect_to repository_shelf_location_url(:id => @shelf_location,
                                                  :repository_id => @repository,
                                                  :download_modal => true)
      else
        redirect_to url_for_dc_identifier(@trackable_item)
      end
    else
      render :action => 'new'
    end
  end

  def update
    @trackable_item_shelf_location = TrackableItemShelfLocation.find(params[:id])

    if params[:event]
      original_state = @trackable_item_shelf_location.current_state
      event_method = params[:event] + '!'
      @trackable_item_shelf_location.send(event_method)
      @successful = @trackable_item_shelf_location.current_state != original_state
      @state_change_failed = @succesful
    else
      @successful = @trackable_item_shelf_location.update_attributes(params[:shelf_location])
    end

    if @successful || @state_change_failed
      flash[:notice] = t('shelf_locations.update.state_change_failed', :event_transition => params[:event].humanize) if @state_change_failed

      url = repository_shelf_location_url(:id => @trackable_item_shelf_location.shelf_location,
                                          :repository_id => @trackable_item_shelf_location.shelf_location.repository)
      redirect_to url
    else
      render :action => 'edit'
    end
  end

  def bulk_allocation
    @basket_options = Basket.find(:all, :conditions=> ['id in (SELECT t.basket_id FROM topics t WHERE extended_content LIKE ?)', '%legacy_identifier%'])
    render
  end

  def bulk_import
    file = File.new("#{Rails.root.to_s}/tmp/import-#{Time.now.strftime '%Y%m%d-%H%M%S'}.xlsx", "w")
    file.write(params[:import].read)
    file.close
    BulkAllocation.import(file.path)
    File.delete file.path
    redirect_to :action => 'bulk_allocation'
  end

  def generate_export
    basket = Basket.find(params[:basket_id] )
    file = BulkAllocation.export(basket)
    headers["Content-Disposition"] = "attachment; filename=#{File.basename file.path}"
    send_data file.read, :filename => File.basename(file.path)
  end
end
