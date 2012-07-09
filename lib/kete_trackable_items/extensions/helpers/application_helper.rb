ApplicationHelper.module_eval do
  # a copy of auto_complete plugin's method, but adding id to li
  def auto_complete_result_with_id(entries, field, phrase = nil)
    return unless entries
    items = entries.map do |entry|
      content_tag("li",
                  phrase ? highlight(entry[field], phrase) : h(entry[field]),
                  :id => "#{field}-id-#{entry.id}")
    end
    content_tag("ul", items.uniq)
  end

  # alias versions of method so far to add to them
  alias_method :superseded_add_ons_basket_admin_list, :add_ons_basket_admin_list

  def add_ons_basket_admin_list
    html = superseded_add_ons_basket_admin_list

    html += "| " + link_to_unless_current(t('application_helper.add_ons_basket_admin_list.location_admin'),
                                          { :controller => :repositories,
                                            :action => :index,
                                            :urlified_name => @current_basket.urlified_name},
                                          :tabindex => '2')

    if @current_basket.repositories.count > 0
      if @current_basket.repositories.count == 1
        button_html = button_to(t('application_helper.add_ons_basket_admin_list.location_tracking'),
                                repository_tracking_lists_url(:repository_id => @current_basket.repositories.first,
                                                              :method => :post),
                                :tabindex => '2')
        html += javascript_tag("jQuery('#basket-toolbox').append('#{button_html}');")
      else

        html += "| " + link_to_redbox(t('application_helper.add_ons_basket_admin_list.location_tracking'),
                                      'RB-choose-repository',
                                      :tabindex => '2')
        html += hidden_repository_new_tracking_list_chooser
      end
    end

    html
  end

  def hidden_repository_new_tracking_list_chooser
    # choose a repository
    html = '<div id="RB-choose-repository" style="display: none;">'
    html += '<div style="margin: 20px;">'
    html += "<h3>#{t('application_helper.add_ons_basket_admin_list.choose_repository')}</h3>"
    html += '</div>'
    @current_basket.repositories.each do |repository|
      html += '<div style="margin: 20px;">'
      html += button_to(repository.name,
                        repository_tracking_lists_url(:repository_id => repository,
                                                      :method => :post),
                        :tabindex => '2')
      html += '</div>'
    end
    
    html += '<div style="text-align: right; margin-right: 20px; margin-bottom: 20px;">'
    html += link_to_close_redbox(t('application_helper.hidden_repository_new_tracking_list_chooser.cancel'))
    html += '</div>'
    html += '</div>'

    javascript_tag("jQuery('body').append('#{html}');")
  end
end
