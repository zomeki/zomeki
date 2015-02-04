# encoding: utf-8
class BizCalendar::Piece::Holiday < Cms::Piece
  default_scope where(model: 'BizCalendar::Holiday')

  def content
    BizCalendar::Content::Place.find(super)
  end

  def target_node
    content.public_nodes.find_by_id(setting_value(:target_node_id))
  end
end
