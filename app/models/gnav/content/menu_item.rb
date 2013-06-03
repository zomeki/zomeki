# encoding: utf-8
class Gnav::Content::MenuItem < Cms::Content
  default_scope where(model: 'Gnav::MenuItem')

  has_many :menu_items, :foreign_key => :content_id, :class_name => 'Gnav::MenuItem', :order => :sort_no, :dependent => :destroy

  before_create :set_default_settings

  def menu_item_node
    return @menu_item_node if @menu_item_node
    @menu_item_node = Cms::Node.where(state: 'public', content_id: id, model: 'Gnav::MenuItem').order(:id).first
  end

  def gp_category_content_category_type
    GpCategory::Content::CategoryType.find_by_id(setting_value(:gp_category_content_category_type_id))
  end

  def category_types
    gp_category_content_category_type.try(:category_types) || []
  end

  def list_style
    setting_value(:list_style) || ''
  end

  def date_style
    setting_value(:date_style) || ''
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title(@date @group)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
  end
end
