# encoding: utf-8
class Gnav::Public::Piece::DocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gnav::Piece::Doc.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    piece_category_ids = @piece.categories.map(&:id)

    piece_doc_ids = find_public_docs_by_category_ids(piece_category_ids).map(&:id)

    case @item
    when Gnav::MenuItem
      page_category_ids = @item.categories.map(&:id)
    end

    if page_category_ids
      page_doc_ids = find_public_docs_by_category_ids(page_category_ids).map(&:id)
      doc_ids = piece_doc_ids & page_doc_ids
    else
      doc_ids = piece_doc_ids
    end

    @docs = GpArticle::Doc.where(id: doc_ids).order('published_at DESC').limit(@piece.list_count)
  end

  private

  def find_public_docs_by_category_ids(category_ids)
    GpArticle::Doc.mobile(::Page.mobile?).public.joins('INNER JOIN gp_article_docs_gp_category_categories AS gadgcc ON gp_article_docs.id = gadgcc.doc_id').where('gadgcc.category_id' => category_ids)
  end
end
