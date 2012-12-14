# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  has_many :category_types, :foreign_key => :content_id, :class_name => 'GpArticle::CategoryType', :order => :sort_no,          :dependent => :destroy
  has_many :docs,           :foreign_key => :content_id, :class_name => 'GpArticle::Doc',          :order => 'updated_at DESC', :dependent => :destroy

  def category_type_node
    return @category_type_node if @category_type_node
    @category_type_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::CategoryType').order(:id).first
  end

  def doc_node
    return @doc_node if @doc_node
    @doc_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Doc').order(:id).first
  end
end
