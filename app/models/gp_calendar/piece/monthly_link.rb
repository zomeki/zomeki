# encoding: utf-8
class GpCalendar::Piece::MonthlyLink < Cms::Piece
  default_scope where(model: 'GpCalendar::MonthlyLink')

  def content
    GpCalendar::Content::Event.find(super)
  end
end
