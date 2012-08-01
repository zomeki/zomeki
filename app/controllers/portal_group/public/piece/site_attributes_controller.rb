# encoding: utf-8
class PortalGroup::Public::Piece::SiteAttributesController < Sys::Controller::Public::Base
  def index
    @content = PortalGroup::Content::Group.find(Page.current_piece.content_id)
    
    if Page.current_node.model =~ /^PortalGroup::(Category|Business|Attribute|Area)$/
      @node = @content.attribute_node
    else
      @node = @content.site_attribute_node
    end
    
    @item  = Page.current_item
    @items = []
    
    if @node
      @public_uri = @node.public_uri
      
      if !@item.instance_of?(PortalGroup::Attribute)
        @items = PortalGroup::Attribute.root_items(:content_id => @content.id)
      else
        @items = []
      end
    end
    
    return render :text => '' if @items.size == 0
  end
end
