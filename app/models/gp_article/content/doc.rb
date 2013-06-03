# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  default_scope where(model: 'GpArticle::Doc')

  has_many :docs, :foreign_key => :content_id, :class_name => 'GpArticle::Doc', :order => 'published_at DESC, updated_at DESC', :dependent => :destroy

  before_create :set_default_settings

  def preview_docs
    docs.mobile(::Page.mobile?)
  end

  def public_docs
    docs.mobile(::Page.mobile?).public
  end

  def doc_node
    return @doc_node if @doc_node
    @doc_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Doc').order(:id).first
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

  def tag_content_tag
    Tag::Content::Tag.find_by_id(setting_value(:tag_content_tag_id))
  end

  def save_button_states
    YAML.load(setting_value(:save_button_states).presence || '[]')
  end

  def required_recognizers
    ids = YAML.load(setting_value(:required_recognizers).presence || '[]')
    Sys::User.where(id: ids)
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title(@date @group)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
  end
end
