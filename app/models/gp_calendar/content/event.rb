# encoding: utf-8
class GpCalendar::Content::Event < Cms::Content
  default_scope where(model: 'GpCalendar::Event')

  def event_node
    return @event_node if @event_node
    @event_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpCalendar::Event').order(:id).first
  end
end
