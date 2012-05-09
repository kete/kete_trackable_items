class TrackingListsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  before_filter :set_repository
  before_filter :set_tracking_list, :except => [:index, :create, :new]

  def show
  end

  def index
    @tracking_lists = TrackingList.all
  end

  def create
    @tracking_list = @repository.tracking_lists.build(params[:tracking_list])

    if @tracking_list.save
      redirect_to tracking_list_url(:id => @tracking_list)
    end
  end

  def destroy
    @tracking_list.destroy

    # TODO: this redirect may need to redirect a different place in some contexts
    redirect_to tracking_list_url(:id => @tracking_list)
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end

  def set_tracking_list
    @tracking_list = @repository.tracking_lists.find(params[:id])
  end
end
