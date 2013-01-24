# encoding: utf-8
class GpCategory::Content::CategoryType < Cms::Content
  default_scope where(model: 'GpCategory::CategoryType')

  has_many :category_types, :foreign_key => :content_id, :class_name => 'GpCategory::CategoryType', :order => :sort_no, :dependent => :destroy

  def category_type_node
    return @category_type_node if @category_type_node
    @category_type_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpCategory::CategoryType').order(:id).first
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
end
