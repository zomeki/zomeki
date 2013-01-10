# encoding: utf-8
class GpCategory::Public::Piece::DocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::Doc.find_by_id(Page.current_piece.id)
    return http_error(404) unless @piece

    @item = Page.current_item
  end

  def index
    unless @piece.category_type
      piece_category_ids = @piece.category_types.map{|ct| ct.categories.map(&:id) }.flatten
    else
      piece_category_ids = @piece.categories.map(&:id)
    end

    piece_doc_ids = GpArticle::Doc.where(state: 'public').joins('INNER JOIN gp_article_docs_gp_category_categories AS gadgcc ON gp_article_docs.id = gadgcc.doc_id').where('gadgcc.category_id' => piece_category_ids).map(&:id)

    case @item
    when GpCategory::CategoryType
      page_category_ids = @item.categories.map(&:id)
    when GpCategory::Category
      page_category_ids = @item.descendants.map(&:id)
    end

    if page_category_ids
      page_doc_ids = GpArticle::Doc.where(state: 'public').joins('INNER JOIN gp_article_docs_gp_category_categories AS gadgcc ON gp_article_docs.id = gadgcc.doc_id').where('gadgcc.category_id' => page_category_ids).map(&:id)
      doc_ids = piece_doc_ids & page_doc_ids
    else
      doc_ids = piece_doc_ids
    end

    @docs = GpArticle::Doc.where(id: doc_ids).order('published_at DESC').limit(@piece.list_count)
  end
end
