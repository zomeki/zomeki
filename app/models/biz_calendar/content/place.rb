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

  private

  def set_default_settings
#    in_settings[:list_style] = '@title_link@' unless setting_value(:list_style)
#    in_settings[:date_style] = '%Y年%m月%d日（%a）' unless setting_value(:date_style)
#    in_settings[:show_images] = 'visible' unless setting_value(:show_images)
  end
end