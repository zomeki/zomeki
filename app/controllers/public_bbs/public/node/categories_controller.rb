# encoding: utf-8
require 'will_paginate/array'
class PublicBbs::Public::Node::CategoriesController < Cms::Controller::Public::Base
  def pre_dispatch
    content = Page.current_node.content
    @content = PublicBbs::Content::Thread.find(content) if content.model == 'PublicBbs::Thread'
    return http_error(404) unless @content

    if params[:name]
      item = PublicBbs::Category.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end

  def index
    @items = PublicBbs::Category.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    category_ids = [@item.id].concat(@item.public_descendants)

    sort = case params[:sort]
           when 't_d'; 'last_updated_at DESC, updated_at DESC'
           when 'n_d'; 'num_reses DESC, updated_at DESC'
           end

    thread = PublicBbs::Thread.new.public
    thread.and :content_id, @content.id
    thread.category_is PublicBbs::Category.find(category_ids)
    thread.page params[:page], 20
    thread.order sort, 'updated_at DESC'

    select_from_pbr = "(SELECT %s FROM public_bbs_responses AS pbr WHERE pbr.thread_id = public_bbs_threads.id AND pbr.state = 'public')"
    num_reses = select_from_pbr % 'COUNT(pbr.id)'
    last_reses_updated_at = select_from_pbr % 'MAX(pbr.updated_at)'
    thread_updated_at = 'public_bbs_threads.updated_at'
    @threads = thread.find(:all, :select => "public_bbs_threads.*, #{num_reses} AS num_reses, IF(#{last_reses_updated_at} > #{thread_updated_at}, #{last_reses_updated_at}, #{thread_updated_at}) AS last_updated_at").select{|t| t.content.thread_node }.paginate

    return http_error(404) if @threads.current_page > @threads.total_pages
  end
end
