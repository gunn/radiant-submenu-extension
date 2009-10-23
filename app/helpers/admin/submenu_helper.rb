module Admin::SubmenuHelper

  def self.included(base)
    base.class_eval do

      def links_for_navigation_with_submenu
        %{
          <div id="navigation_tabs">#{links_for_navigation_without_submenu}</div>
          #{navigation_submenu}
        }
      end
      alias_method_chain :links_for_navigation, :submenu

      def navigation_submenu
        current_tab = admin.tabs.find{ |tab| current_url?(urlize_path(tab.url)) }
        standard_links = site_chooser + navigation_submenu_links
        tab_links = current_tab.submenu.map{|link| nav_link_to(link.name, urlize_path(link.url)) }.join(separator) if current_tab && current_tab.has_submenu?
        %{<div id="submenu">#{standard_links}<div id="tabmenu">#{tab_links}</div></div>}
      end
      
      # these are the non-tab-related links added on a per-site or per-user basis through the admin interface
      
      def navigation_submenu_links
        links = SubmenuLink.visible_to(current_user).map {|link| link_to(link.name, urlize_path(link.url)) }
        links << link_to("edit menu", admin_submenu_links_url, :class => 'admin') if admin?
        %{<div id="submenu_links">#{links.join(separator)}</div>} if links.any?
      end

      # and under multi_site this builds a site-chooser whenever the foreground model is site_scoped

      def site_chooser
        return "" unless admin? && defined?(Site) && controller.sited_model? && Site.several?
        options = Site.find(:all).map{ |site| "<li>" + link_to( site.name, "#{request.path}?site_id=#{site.id}", :class => site == current_site ? 'fg' : '') + "</li>" }
        chooser = %{<div id="site_chooser">}
        chooser << link_to("sites", admin_sites_url, {:id => 'show_site_list', :class => 'expandable'})
        chooser << %{<ul class="expansion" id="site_list">#{options}</ul>}
        chooser << %{</div>}
        chooser
      end

      def urlize_path(url)
        File.join(ActionController::Base.relative_url_root || '', url)
      end

    end
  end
end