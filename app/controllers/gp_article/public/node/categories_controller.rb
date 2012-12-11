# encoding: utf-8

require 'will_paginate/array'

class GpArticle::Public::Node::CategoriesController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def show
#TODO: Check ancestors
p params[:ancestors]
p params[:name]
    @category = GpArticle::Category.find_by_name(params[:name])
    return http_error(404) unless @category
  end
end
