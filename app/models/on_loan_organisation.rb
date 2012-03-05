# name
# address, contact details?
# used in Item when current_location is on_loan

# TODO: maybe need to add optional association between repository and on_loan_organisation

# quote from spec: When archives are tracked to “On Loan” additional information is required i.e. to what organization / office they will be loaned to.  This is a list that will need to be maintained by Staff as it could be continually added to. This list may need to be separate for each Archives Repository as to prevent clutter for the other councils.
class OnLoanOrganisation < ActiveRecord::Base
  
end