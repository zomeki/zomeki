# encoding: utf-8
class GpCategory::Content::CategoryType < Cms::Content
  default_scope where(model: 'GpCategory::CategoryType')

  has_many :category_types, :foreign_key => :content_id, :class_name => 'GpCategory::CategoryType', :order => :sort_no, :dependent => :destroy

  before_create :set_default_settings

  def category_type_node
    return @category_type_node if @category_type_node
    @category_type_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpCategory::CategoryType').order(:id).first
  end

  def public_category_types
    category_types.public
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  def group_category_type_name
    setting_value(:group_category_type_name).presence || 'groups'
  end

  def group_category_type
    category_types.find_by_name(group_category_type_name)
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
