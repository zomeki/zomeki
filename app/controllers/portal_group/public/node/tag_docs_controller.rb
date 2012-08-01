# encoding: utf-8
require 'will_paginate/array'
class PortalGroup::Public::Node::TagDocsController < Cms::Controller::Public::Base
  include PortalGroup::Controller::Feed
  
  def index
    return http_error(404) unless @content = Page.current_node.content
    
    @base_uri = Page.current_node.public_uri
    return redirect_to(@base_uri) if params[:reset]
    
    @tag = params[:tag] || params[:s_tag]
    @tag = @tag.to_s.force_encoding('utf-8')
    
    if request.post? || @tag =~ / /
      @tag = @tag.strip.gsub(/ .*/, '')
      return redirect_to("#{@base_uri}#{CGI::escape(@tag)}")
    end
    
    
    if @tag
      doc = PortalArticle::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :portal_group_id, @content.id
      doc.and :portal_group_state, "visible"
      doc.and 'language_id', 1
      doc.and 0, 1 if @tag.to_s == ''
      qw = doc.connection.quote_string(@tag).gsub(/([_%])/, '\\\\\1')
      doc.and "sql", "EXISTS (SELECT * FROM portal_article_tags WHERE portal_article_docs.unid = portal_article_tags.unid AND word LIKE '#{qw}%') "
      doc.page params[:page], (request.mobile? ? 20 : 50)
      # 単独表示するためのディレクトリが割り当てられていないスレッドは除外
      @docs = doc.find(:all, :order => 'published_at DESC').select{|d| d.content.doc_node }.paginate
    else
      @docs = Array.new.paginate
    end
    
    return true if render_feed(@docs)
  end
end
