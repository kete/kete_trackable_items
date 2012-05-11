module KeteTrackableItems
  module ControllerHelpers
    def appropriate_repositories_for_basket
      @current_basket == @site_basket ? Repository.all : @current_basket.repositories
    end
  end
end
