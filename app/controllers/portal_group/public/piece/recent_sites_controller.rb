# encoding: utf-8
class PortalGroup::Public::Piece::RecentSitesController < Sys::Controller::Public::Base
  helper PortalGroup::DocHelper
  
  def index
    @piece   = Page.current_piece
    @content = PortalGroup::Content::Group.find(@piece.content_id)
    @node = @content.site_node
    
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10
    
    item = Cms::Site.new.public
    item.and :portal_group_id, @content.id
    item.and :portal_group_state, "visible"
    item.page 1, limit
    @sites = item.find(:all, :order => "created_at DESC")
  end
end
