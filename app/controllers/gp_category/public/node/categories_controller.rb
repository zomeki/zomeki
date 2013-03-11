# encoding: utf-8

require 'will_paginate/array'

class GpCategory::Public::Node::CategoriesController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def show
    category_type = @content.category_types.find_by_name(params[:category_type_name])
    @category = category_type.find_category_by_path_from_root_category(params[:category_names])
    return http_error(404) unless @category

    Page.current_item = @category
    Page.title = @category.title

    render :show_mobile if Page.mobile?
  end
end
