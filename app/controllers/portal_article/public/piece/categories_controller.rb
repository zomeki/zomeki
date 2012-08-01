# encoding: utf-8
class PortalArticle::Public::Piece::CategoriesController < Sys::Controller::Public::Base
  def index
    @content = PortalArticle::Content::Doc.find(Page.current_piece.content_id)
    @node = @content.category_node
    
    @item = Page.current_item
    @items = []
    
    if @node
      @public_uri = @node.public_uri
      
      if !@item.instance_of?(PortalArticle::Category)
        @items = PortalArticle::Category.root_items(:content_id => @content.id)
      else
        @items = @item.public_children
      end
    end
    
    return render :text => '' if @items.size == 0
  end
end
