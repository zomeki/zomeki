# encoding: utf-8
class Gnav::Content::MenuItem < Cms::Content
  default_scope where(model: 'Gnav::MenuItem')

  has_many :menu_items, :foreign_key => :content_id, :class_name => 'Gnav::MenuItem', :order => :sort_no, :dependent => :destroy

  def gp_category_content_category_type
    GpCategory::Content::CategoryType.find_by_id(setting_value(:gp_category_content_category_type_id))
  end

  def menu_item_node
    return @menu_item_node if @menu_item_node
    @menu_item_node = Cms::Node.where(state: 'public', content_id: id, model: 'Gnav::MenuItem').order(:id).first
  end
end
