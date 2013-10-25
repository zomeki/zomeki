# encoding: utf-8

require 'will_paginate/array'

class GpCategory::Public::Node::CategoryTypesController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @category_types = @content.public_category_types.paginate(page: params[:page], per_page: 20)
    return http_error(404) if @category_types.current_page > @category_types.total_pages

    render :index_mobile if Page.mobile?
  end

  def show
    @category_type = @content.public_category_types.find_by_name(params[:name])
    return http_error(404) unless @category_type

    Page.current_item = @category_type
    Page.title = @category_type.title

    case @content.category_type_style
    when 'all_docs'
      category_ids = @category_type.public_categories.map(&:id)
      @docs = GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_ids).mobile(::Page.mobile?).public
                            .order('display_published_at DESC, published_at DESC').paginate(page: params[:page], per_page: @content.category_type_docs_number)
      return true if render_feed(@docs)
      return http_error(404) if @docs.current_page > @docs.total_pages
    else
      return http_error(404) if params[:format].in?('rss', 'atom')
      return http_error(404) if params[:page].to_i > 1
    end

    if Page.mobile?
      render :show_mobile
    else
      if (style = @content.category_type_style).present?
        render style
      end
    end
  end
end
