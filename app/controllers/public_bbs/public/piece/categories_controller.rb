# encoding: utf-8
class PublicBbs::Public::Piece::CategoriesController < Sys::Controller::Public::Base
  def index
    @content = PublicBbs::Content::Thread.find(Page.current_piece.content)
    @node = @content.category_node

    @items = []

    if @node
      @public_uri = @node.public_uri
      @items = PublicBbs::Category.root_items(:content_id => @content.id)
    end

    return render :text => '' if @items.empty?
  end
end
