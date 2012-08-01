# encoding: utf-8
class PortalArticle::Public::Node::RecentDocsController < Cms::Controller::Public::Base
  include PortalArticle::Controller::Feed
  
  def index
    @content = Page.current_node.content
    
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id
    #doc.search params
    doc.page params[:page], (request.mobile? ? 20 : 50)
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
