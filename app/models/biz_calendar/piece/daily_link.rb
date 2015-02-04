# encoding: utf-8
class BizCalendar::Piece::DailyLink < Cms::Piece
  default_scope where(model: 'BizCalendar::DailyLink')

  def content
    BizCalendar::Content::Place.find(super)
  end

  def target_node
    content.public_nodes.find_by_id(setting_value(:target_node_id))
  end
end
