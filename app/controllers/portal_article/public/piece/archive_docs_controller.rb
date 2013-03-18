# encoding: utf-8
class PortalArticle::Public::Piece::ArchiveDocsController < Sys::Controller::Public::Base
  def index
    @piece   = Page.current_piece
    @content = PortalArticle::Content::Doc.find(@piece.content_id)
    @node = @content.recent_node
    
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10
    
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id
    #doc.visible_in_recent
    doc.page 1, limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    
    prev   = nil
    @items = []
    @docs.each do |doc|
      next unless doc.published_at
      date = doc.published_at.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? doc.published_at.strftime('%Y年%-m月%-d日') : nil),
        :doc  => doc
      }
      prev = date    
    end
  end
end
