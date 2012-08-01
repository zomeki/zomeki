# encoding: utf-8
class PortalGroup::Public::Piece::SiteBusinessesController < Sys::Controller::Public::Base
  def index
    @content = PortalGroup::Content::Group.find(Page.current_piece.content_id)
    
    if Page.current_node.model =~ /^PortalGroup::(Category|Business|Attribute|Area)$/
      @node = @content.business_node
    else
      @node = @content.site_business_node
    end
    
    @item  = Page.current_item
    @items = []
    
    if @node
      @public_uri = @node.public_uri
      
      if !@item.instance_of?(PortalGroup::Business)
        @items = PortalGroup::Business.root_items(:content_id => @content.id)
      else
        @items = @item.public_children
      end
    end
    
    return render :text => '' if @items.size == 0
  end
end
