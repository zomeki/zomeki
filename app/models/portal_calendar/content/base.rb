# encoding: utf-8
class PortalCalendar::Content::Base < Cms::Content
  def event_node
    return @event_node if @event_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalCalendar::List'
    @doc_node = item.find(:first, :order => :id)
  end
end