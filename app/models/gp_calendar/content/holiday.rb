# encoding: utf-8
class GpCalendar::Content::Holiday < Cms::Content
  IMAGE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  default_scope where(model: 'GpCalendar::Holiday')

  has_many :holidays, :foreign_key => :content_id, :class_name => 'GpCalendar::Holiday', :dependent => :destroy

  before_create :set_default_settings

  def public_nodes
    nodes.public
  end

  def public_node
    public_nodes.order(:id).first
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def show_images?
    setting_value(:show_images) == 'visible'
  end

  def default_image
    setting_value(:default_image).to_s
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日（%a）' unless setting_value(:date_style)
    in_settings[:show_images] = 'visible' unless setting_value(:show_images)
  end
end
