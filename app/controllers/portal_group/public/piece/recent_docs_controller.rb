# encoding: utf-8
class PortalGroup::Public::Piece::RecentDocsController < Sys::Controller::Public::Base
  helper PortalGroup::DocHelper
  
  def index
    @piece   = Page.current_piece
    @content = PortalGroup::Content::Group.find(@piece.content_id)
    @node = @content.recent_node
    
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10
    
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :portal_group_id, @content.id
    doc.and :portal_group_state, "visible"
    #doc.visible_in_recent
    doc.page 1, limit
    @docs = doc.find(:all, :order => 'published_at DESC')
  end
end
