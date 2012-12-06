# encoding: utf-8

require 'will_paginate/array'

class GpArticle::Public::Node::CategoryTypesController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def show
    @category_type = GpArticle::CategoryType.find_by_name(Page.current_node.name)
    return http_error(404) unless @category_type
  end
end
