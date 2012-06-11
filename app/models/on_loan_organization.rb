# -*- coding: utf-8 -*-
# name
# address, contact details?
# used in Item when current_location is on_loan

# quote from spec: When archives are tracked to “On Loan” additional information is required i.e. to what organization / office they will be loaned to.  This is a list that will need to be maintained by Staff as it could be continually added to. This list may need to be separate for each Archives Repository as to prevent clutter for the other councils.
class OnLoanOrganization < ActiveRecord::Base
  # tracking history, only historical_receiver
  send :has_many, :tracking_receiving_events, :as => :historical_receiver, :dependent => :delete_all

  def name_for_tracking_event
    name
  end
end
