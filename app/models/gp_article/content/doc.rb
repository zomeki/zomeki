# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  default_scope where(model: 'GpArticle::Doc')

  has_many :docs, :foreign_key => :content_id, :class_name => 'GpArticle::Doc', :order => 'published_at DESC, updated_at DESC', :dependent => :destroy

  def public_docs
    docs.public
  end

  def doc_node
    return @doc_node if @doc_node
    @doc_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Doc').order(:id).first
  end

  def tag_node
    return @tag_node if @tag_node
    @tag_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Tag').order(:id).first
  end

  def gp_category_content_category_type
    GpCategory::Content::CategoryType.find_by_id(setting_value(:gp_category_content_category_type_id))
  end

  def category_types
    setting = GpArticle::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    if (cts = gp_category_content_category_type.try(:category_types))
      cts.where(id: setting.try(:category_type_ids))
    else
      []
    end
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  def visible_category_types
    setting = GpArticle::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    if (cts = gp_category_content_category_type.try(:category_types))
      cts.where(id: setting.try(:visible_category_type_ids))
    else
      []
    end
  end

  def default_category_type
    setting = GpArticle::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    GpCategory::CategoryType.find_by_id(setting.try(:default_category_type_id))
  end

  def default_category
    setting = GpArticle::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    GpCategory::Category.find_by_id(setting.try(:default_category_id))
  end

  def group_category_type
    return nil unless gp_category_content_category_type
    gp_category_content_category_type.group_category_type
  end

  def list_style
    setting_value(:list_style) || ''
  end

  def date_style
    setting_value(:date_style) || ''
  end
end
