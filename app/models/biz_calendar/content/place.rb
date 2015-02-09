# encoding: utf-8
class BizCalendar::Content::Place < Cms::Content

  default_scope where(model: 'BizCalendar::Place')

  has_many :places, :foreign_key => :content_id, :class_name => 'BizCalendar::Place', :dependent => :destroy
  has_many :types, :foreign_key => :content_id, :class_name => 'BizCalendar::HolidayType', :dependent => :destroy

  before_create :set_default_settings

  def public_nodes
    nodes.public
  end

  def public_node
    public_nodes.order(:id).first
  end

  def public_places
    places.public
  end

  def visible_types
    types.visible
  end

  def month_number
    setting_value(:month_number).to_i
  end

  def show_month_number
    setting_value(:show_month_number).to_i
  end

  def date_style
    setting_value(:date_style).to_s.present? ? setting_value(:date_style).to_s : '%Y年%m月%d日 %H時%M分'
  end

  def time_style
    setting_value(:time_style).to_s.present? ? setting_value(:time_style).to_s : '%H時%M分'
  end

  private

  def set_default_settings
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
    in_settings[:time_style] = '%H時%M分' unless setting_value(:time_style)
  end
end