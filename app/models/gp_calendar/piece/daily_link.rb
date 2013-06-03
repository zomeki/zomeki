# encoding: utf-8
class GpCalendar::Piece::DailyLink < Cms::Piece
  default_scope where(model: 'GpCalendar::DailyLink')

  def content
    GpCalendar::Content::Event.find(super)
  end
end
