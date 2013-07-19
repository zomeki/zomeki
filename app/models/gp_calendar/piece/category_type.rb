# encoding: utf-8
class GpCalendar::Piece::CategoryType < Cms::Piece
  default_scope where(model: 'GpCalendar::CategoryType')

  def content
    GpCalendar::Content::Event.find(super)
  end
end
