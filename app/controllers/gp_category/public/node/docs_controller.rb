# encoding: utf-8
class GpCategory::Public::Node::DocsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    categories = @content.public_category_types.inject([]) {|result, ct|
                     result | ct.public_root_categories.inject([]) {|r, c| r | c.descendants }
                   }
    @docs = GpArticle::Doc.all_with_content_and_criteria(nil, category_id: categories.map(&:id)).mobile(::Page.mobile?).public
                          .paginate(page: params[:page], per_page: @content.doc_docs_number)
    return true if render_feed(@docs)
    return http_error(404) if @docs.current_page > @docs.total_pages

    if Page.mobile?
      render :index_mobile
    else
      if (style = @content.doc_style).present?
        render style
      end
    end
  end
end
