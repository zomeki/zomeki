# encoding: utf-8
class GpCategory::Piece::RecentTabXml < Cms::Model::Base::PieceExtension
  CONDITION_OPTIONS = [['すべてを含む', 'and'], ['いずれかを含む', 'or']]

  set_model_name 'gp_category/piece/recent_tab'
  set_column_name :xml_properties
  set_node_xpath 'groups/group'
  set_primary_key :name

  attr_accessor :name
  attr_accessor :title
  attr_accessor :more
  attr_accessor :condition
  attr_accessor :sort_no

  elem_accessor :category_ids

  validates_presence_of :name, :title, :sort_no

  def condition_name
    CONDITION_OPTIONS.detect{|o| o.last == condition }.try(:first) || ''
  end

  def categories
    categories_array = []

    category_ids.each do |category_id|
      category = GpCategory::Category.find_by_id(category_id)
      categories_array << category if category
    end

    categories_array.sort do |a, b|
      next a.category_type.sort_no <=> b.category_type.sort_no unless a.category_type.sort_no == b.category_type.sort_no
      next a.category_type.id <=> b.category_type.id unless a.category_type.id == b.category_type.id
      next a.level_no <=> b.level_no unless a.level_no == b.level_no
      next a.parent_id <=> b.parent_id unless a.parent_id == b.parent_id
      next a.sort_no <=> b.sort_no unless a.sort_no == b.sort_no
      a.id <=> b.id
    end
  end
end
