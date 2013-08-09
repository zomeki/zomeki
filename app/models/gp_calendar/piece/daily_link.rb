# encoding: utf-8
class GpCalendar::Piece::DailyLink < Cms::Piece
  default_scope where(model: 'GpCalendar::DailyLink')

  def content
    GpCalendar::Content::Event.find(super)
  end

  def target_node
    content.public_nodes.find_by_id(setting_value(:target_node_id))
  end
end
