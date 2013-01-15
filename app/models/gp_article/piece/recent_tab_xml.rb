# encoding: utf-8
class GpArticle::Piece::RecentTabXml < Cms::Model::Base::PieceExtension
  CONDITION_STATE_OPTIONS = [['すべてを含む', 'and'], ['いずれかを含む', 'or']]

  set_model_name 'gp_article/piece/recent_tab'
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
    CONDITION_STATE_OPTIONS.detect{|o| o.last == condition }.try(:first) || ''
  end

  def categories
    categories_array = []
    category_ids.each do |category_id|
      category = GpCategory::Category.find_by_id(category_id)
      categories_array << category if category
    end
    return categories_array
  end
end
