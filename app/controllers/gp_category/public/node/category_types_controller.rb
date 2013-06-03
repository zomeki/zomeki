# encoding: utf-8

require 'will_paginate/array'

class GpCategory::Public::Node::CategoryTypesController < Cms::Controller::Public::Base
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

    render :show_mobile if Page.mobile?
  end
end
