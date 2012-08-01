# encoding: utf-8
class PortalGroup::Public::Node::SitesController < Cms::Controller::Public::Base
  include PortalGroup::Controller::SiteFeed
  
  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
  end
  
  def index
    item = Cms::Site.new.public
    item.and :portal_group_id, @content.id
    item.and :portal_group_state, "visible"
    #item.search params
    item.page params[:page], (request.mobile? ? 20 : 50)
    @items = item.find(:all, :order => "created_at DESC")
    return true if render_feed(@items)
    
    return http_error(404) if @items.current_page > 1 && @items.current_page > @items.total_pages
  end
end
