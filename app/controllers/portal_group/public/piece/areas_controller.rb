# encoding: utf-8
class PortalGroup::Public::Piece::AreasController < Sys::Controller::Public::Base
  def index
    @content = PortalGroup::Content::Group.find(Page.current_piece.content_id)
    
    if Page.current_node.model =~ /^PortalGroup::Site(|Category|Business|Attribute|Area)$/
      @node = @content.site_area_node
    else
      @node = @content.area_node
    end
    
    @item  = Page.current_item
    @items = []
    
    if @node
      @public_uri = @node.public_uri
      
      if !@item.instance_of?(PortalGroup::Area)
        @items = PortalGroup::Area.root_items(:content_id => @content.id)
      else
        @items = @item.public_children
      end
    end
    
    return render :text => '' if @items.size == 0
  end
end
