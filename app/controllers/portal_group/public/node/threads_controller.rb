# encoding: utf-8
require 'will_paginate/array'
class PortalGroup::Public::Node::ThreadsController < Cms::Controller::Public::Base
  def pre_dispatch
    content = Page.current_node.content
    @content = PortalGroup::Content::Group.find(content) if content.model == 'PortalGroup::Group'
    return http_error(404) unless @content
  end

  def index
    thread = PublicBbs::Thread.new.public
    thread.and :portal_group_id, @content.id
    thread.page params[:page], 50
    thread.order nil, 'updated_at DESC'

    @threads = thread.find(:all).select{|t| t.content.thread_node }.paginate

    return http_error(404) if @threads.current_page > @threads.total_pages
  end
end
