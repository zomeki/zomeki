# encoding: utf-8
class BizCalendar::Piece::BussinessTime < Cms::Piece
  TARGET_TYPE_OPTIONS = [['全て', 'all'], ['本日', 'today']]
  PAGE_FILTER_OPTIONS = [['絞り込む', 'filter'], ['絞り込まない', 'through']]

  default_scope where(model: 'BizCalendar::BussinessTime')

  after_initialize :set_default_settings

  def content
    BizCalendar::Content::Place.find(super)
  end

  def target_today?
    target_type == 'today'
  end

  def target_type
    setting_value(:target_type).presence || 'all'
  end

  def page_filter
    setting_value(:page_filter).presence || 'filter'
  end

  def time_style
    setting_value(:time_style).presence || '%H時%M分'
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['page_filter'] = 'filter' if setting_value(:page_filter).nil?
    settings['time_style'] = '%H時%M分' if setting_value(:time_style).nil?

    self.in_settings = settings
  end
  
end
