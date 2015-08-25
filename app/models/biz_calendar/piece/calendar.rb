# encoding: utf-8
class BizCalendar::Piece::Calendar < Cms::Piece
  HOLIDAY_TYPE_STATE_OPTIONS = [['表示する','visible'],['表示しない','hidden']]
  HOLIDAY_STATE_OPTIONS = [['表示する','visible'],['表示しない','hidden']]

  default_scope where(model: 'BizCalendar::Calendar')

  after_initialize :set_default_settings

  def content
    BizCalendar::Content::Place.find(super)
  end

  def place
    return false if place_id.blank?
    content.public_places.find_by_id(place_id.to_i)
  end

  def place_id
    setting_value(:place_id).presence || false
  end

  def month_number
    (setting_value(:month_number).presence || 1).to_i
  end

  def holiday_type_state
    setting_value(:holiday_type_state).presence || 'hidden'
  end

  def holiday_state
    setting_value(:holiday_state).presence || 'hidden'
  end

  def date_style
    setting_value(:date_style).presence || '%Y年%m月%d日'
  end

  def lower_text
    setting_value(:lower_text).to_s
  end

  def show_holiday_type?
    holiday_type_state == 'visible'
  end

  def show_holiday?
    holiday_state == 'visible'
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['month_number'] = 1 if setting_value(:month_number).nil?
    settings['holiday_type_state'] = 'hidden' if setting_value(:holiday_type_state).nil?
    settings['holiday_state'] = 'hidden' if setting_value(:holiday_state).nil?
    settings['date_style'] = '%Y年%m月%d日' if setting_value(:date_style).nil?

    self.in_settings = settings
  end

end
