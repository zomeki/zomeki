# encoding: utf-8
class GpCategory::Public::Node::CategoriesController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
    @more = (params[:file] == 'more')
  end

  def show
    category_type = @content.category_types.find_by_name(params[:category_type_name])
    @category = category_type.find_category_by_path_from_root_category(params[:category_names])
    return http_error(404) unless @category.try(:public?)

    Page.current_item = @category
    Page.title = @category.title

    per_page = (@more ? 30 : @content.category_docs_number)

    @docs = @category.public_docs.paginate(page: params[:page], per_page: per_page)
    return true if render_feed(@docs)
    return http_error(404) if @docs.current_page > @docs.total_pages

    if Page.mobile?
      render :show_mobile
    else
      if @more
        render 'more'
      else
        if (style = @content.category_style).present?
          render style
        end
      end
    end
  end
end
