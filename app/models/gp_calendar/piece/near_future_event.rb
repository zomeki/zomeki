# encoding: utf-8
class GpCalendar::Piece::NearFutureEvent < Cms::Piece
  default_scope where(model: 'GpCalendar::NearFutureEvent')

  def content
    GpCalendar::Content::Event.find(super)
  end
end
