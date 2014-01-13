class GpArticle::Public::Piece::CommentsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::Comment.find_by_id(Page.current_piece.id)
    return render(text: '') unless @piece

    @item = Page.current_item
  end

  def index
    @comments = case @item
                when GpArticle::Doc
                  @item.public_comments
                else
                  @piece.content.public_comments
                end
  end
end
