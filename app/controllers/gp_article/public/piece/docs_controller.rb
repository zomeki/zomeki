# encoding: utf-8
class GpArticle::Public::Piece::DocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::Doc.find_by_id(Page.current_piece.id)
    @category_type = @piece.category_type
    unless @category_type
      render :text => ''
    else
      @category = @piece.category
    end
  end

  def index
    if @category
      category_ids = @category.descendants.map(&:id)
    else
      category_ids = @category_type.categories.map(&:id)
    end
    @docs = GpArticle::Doc.joins('INNER JOIN gp_article_docs_gp_category_categories AS gadgcc ON gp_article_docs.id = gadgcc.doc_id').where('gadgcc.category_id' => category_ids).order('published_at DESC').limit(@piece.list_count)
  end
end
