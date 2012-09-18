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

    html += tracking_list_create_html
    html
  end

  def hidden_repository_new_tracking_list_chooser(basket, order = nil)
    # choose a repository
    html = '<div id="RB-choose-repository'

    html += "-#{order.id}" if order

    html += '" style="display: none;">'

    html += '<div style="margin: 20px;">'
    html += "<h3>#{t('application_helper.add_ons_basket_admin_list.choose_repository')}</h3>"
    html += '</div>'

    basket.repositories.each do |repository|
      html += '<div style="margin: 20px;">'

      url_hash = {
        :urlified_name => basket.urlified_name,
        :repository_id => repository,
        :method => :post }

      url_hash[:order] = order if order

      html += button_to(repository.name,
                        repository_tracking_lists_url(url_hash),
                        :tabindex => '2')
      html += '</div>'
    end
    
    html += '<div style="text-align: right; margin-right: 20px; margin-bottom: 20px;">'
    html += link_to_close_redbox(t('application_helper.hidden_repository_new_tracking_list_chooser.cancel'))
    html += '</div>'
    html += '</div>'

    javascript_tag("jQuery('body').append('#{html}');")
  end

  def tracking_list_create_html(order = nil)
    html = String.new
    phrase = order.blank? ? t('application_helper.tracking_list_create_html.location_tracking') :
      t('application_helper.tracking_list_create_html.tracking_list_from_order')
    basket = order.blank? ? @current_basket : order.basket
    repositories = basket.repositories
    target_basket = basket
    if basket.repositories.count == 0 && basket != @site_basket
      repositories = @site_basket.repositories
      target_basket= @site_basket
    end

    if repositories.count > 0
      if repositories.count == 1

        url_hash = {
          :urlified_name => target_basket.urlified_name,
          :repository_id => repositories.first,
          :method => :post }

        if order
          url_hash[:order] = order
          html += '<li class="first">' + button_to(phrase,
                                                   repository_tracking_lists_url(url_hash),
                                                   :tabindex => '2') + '</li>'
        else
          button_html = button_to(phrase,
                                  repository_tracking_lists_url(url_hash),
                                  :tabindex => '2')

          html += javascript_tag("jQuery('#basket-toolbox').append('#{button_html}');")
        end
      else

        css_id = 'RB-choose-repository'
        css_id += "-#{order.id}" if order

        html += "| " unless order

        html += link_to_redbox(phrase,
                               css_id,
                               :tabindex => '2')

        html += hidden_repository_new_tracking_list_chooser(target_basket, order)
      end
    end
    html
  end

  def button_or_link_to_create_tracking_list_from(order)
    tracking_list_create_html(order)
  end
end
