# encoding: utf-8
class GpCategory::Public::Piece::DocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::Doc.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    piece_category_ids = @piece.categories.map(&:id)
    piece_docs = find_public_docs_by_category_ids(piece_category_ids)

    unless (gacds = @piece.gp_article_content_docs).empty?
      gacd_ids = gacds.map(&:id)
      piece_docs.select! {|d| gacd_ids.include?(d.content_id) }
    end

    piece_doc_ids = piece_docs.map(&:id)

    case @item
    when GpCategory::CategoryType
      page_category_ids = @item.categories.map(&:id)
    when GpCategory::Category
      page_category_ids = @item.descendants.map(&:id)
    end

    if page_category_ids
      page_doc_ids = find_public_docs_by_category_ids(page_category_ids).map(&:id)
      doc_ids = piece_doc_ids & page_doc_ids
    else
      doc_ids = piece_doc_ids
    end

    @docs = GpArticle::Doc.where(id: doc_ids).limit(@piece.list_count)
    @docs = case @piece.docs_order
            when 'published_at_desc'
              @docs.order('display_published_at DESC, published_at DESC')
            when 'published_at_asc'
              @docs.order('display_published_at ASC, published_at ASC')
            when 'random'
              @docs.order('RAND()')
            else
              @docs
            end

    render :index_mobile if Page.mobile?
  end

  private

  def find_public_docs_by_category_ids(category_ids)
    GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_ids).mobile(::Page.mobile?).public
  end
end
