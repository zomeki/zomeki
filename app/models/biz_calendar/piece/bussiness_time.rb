# encoding: utf-8
class BizCalendar::Piece::BussinessTime < Cms::Piece
  TARGET_TYPE_OPTIONS = [['全て', 'all'], ['本日', 'today']]
  PAGE_FILTER_OPTIONS = [['絞り込む', 'filter'], ['絞り込まない', 'through']]

  default_scope where(model: 'BizCalendar::BussinessTime')

  def content
    BizCalendar::Content::Place.find(super)
  end

  def target_today?
    setting_value(:target_type) == 'today'
  end

  def target_type
    setting_value(:target_type).to_s
  end

  def page_filter
    setting_value(:page_filter).to_s
  end

  def time_style
    setting_value(:time_style).presence || '%H時%M分'
  end

end
