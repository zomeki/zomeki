# encoding: utf-8
require 'will_paginate/array'
class PortalGroup::Public::Node::TagThreadsController < Cms::Controller::Public::Base
  def pre_dispatch
    content = Page.current_node.content
    @content = PortalGroup::Content::Group.find(content) if content.model == 'PortalGroup::Group'
    return http_error(404) unless @content

    @base_uri = Page.current_node.public_uri
    return redirect_to(@base_uri) if params[:reset]
  end

  def index
    @tag = params[:tag] || params[:s_tag]
    @tag = @tag.to_s.force_encoding('utf-8')

    if request.post? || @tag =~ / /
      @tag = @tag.strip.gsub(/ .*/, '')
      return redirect_to("#{@base_uri}#{CGI::escape(@tag)}")
    end

    if @tag
      thread = PublicBbs::Thread.new.public
      thread.and :portal_group_id, @content.id
      thread.and 0, 1 if @tag.to_s == ''
      qw = thread.connection.quote_string(@tag).gsub(/([_%])/, '\\\\\1')
      thread.and 'sql', "EXISTS (SELECT * FROM public_bbs_tags WHERE public_bbs_threads.unid = public_bbs_tags.unid AND word LIKE '#{qw}%') "
      thread.page params[:page], 50
      # 単独表示するためのディレクトリが割り当てられていないスレッドは除外
      @threads = thread.find(:all, :order => 'updated_at DESC').select{|t| t.content.thread_node }.paginate
    else
      @threads = Array.new.paginate
    end
  end
end
