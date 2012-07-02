module OnLoanOrganizationsHelper
  # WARNING: not working, doesn't clear id as stands
  def javascript_on_loan_organization_name_clear_also_clear_id
    javascript_tag("
      jQuery('#on_loan_organization_name').bind('keyup mouseup change', function() {
        if (jQuery('#on_loan_organization_name_auto_complete ul li').size() == 0) {
          jQuery(\"#on_loan_organization_id\").val('');
        }
      }); ")
  end

  def javascript_on_loan_organization_id_change_update_contact_details
    javascript_tag("
      jQuery('#on_loan_organization_id').change(function() {
        var id = jQuery('#on_loan_organization_id').val;
        if (id === '' || typeof id === 'undefined') {
          jQuery(\"#on_loan_organization_contact_details\").show();
          jQuery(\"#label_for_on_loan_organization_contact_details\").text('#{t('on_loan_organizations.new.contact_details_label')}');
        }
      }); ")
  end
end
