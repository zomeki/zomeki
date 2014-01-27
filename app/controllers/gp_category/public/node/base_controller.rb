class GpCategory::Public::Node::BaseController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
    @more = (params[:file] == 'more')
  end

  private

  def find_public_docs_with_category_ids(category_ids)
    GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_ids).except(:order).mobile(::Page.mobile?).public
  end
end
