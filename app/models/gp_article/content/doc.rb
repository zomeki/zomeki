# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  default_scope where(model: 'GpArticle::Doc')

  has_many :docs, :foreign_key => :content_id, :class_name => 'GpArticle::Doc', :order => 'published_at DESC, updated_at DESC', :dependent => :destroy

  def public_docs
    docs.where(state: 'public')
  end

  def doc_node
    return @doc_node if @doc_node
    @doc_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Doc').order(:id).first
  end

  def gp_category_content_category_type
    GpCategory::Content::CategoryType.find_by_id(setting_value(:gp_category_content_category_type_id))
  end

  def category_types
    if (cts = gp_category_content_category_type.try(:category_types))
      cts.where(id: (setting_extra_value(:gp_category_content_category_type_id) || '').split(','))
    else
      []
    end
  end

  def group_category_type
    return nil unless gp_category_content_category_type
    gp_category_content_category_type.group_category_type
  end
end
