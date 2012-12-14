# encoding: utf-8

require 'will_paginate/array'

class GpArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @docs = @content.docs.paginate(page: params[:page], per_page: 20)
    return http_error(404) if @docs.current_page > @docs.total_pages
  end

  def show
    @doc = @content.docs.find_by_id(params[:id])
    return http_error(404) unless @doc
  end
end
