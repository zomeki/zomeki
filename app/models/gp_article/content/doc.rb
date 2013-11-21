# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  CALENDAR_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  MAP_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  APPROVAL_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]

  default_scope where(model: 'GpArticle::Doc')

  has_many :docs, :foreign_key => :content_id, :class_name => 'GpArticle::Doc', :dependent => :destroy

  before_create :set_default_settings

  def all_docs
    docs.unscoped
  end

  def preview_docs
    docs.unscoped.mobile(::Page.mobile?)
  end

  def public_docs
    docs.unscoped.mobile(::Page.mobile?).public
  end

  def public_node
    Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Doc').order(:id).first
  end

#TODO: DEPRECATED
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
      GpCategory::CategoryType.none
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
      GpCategory::CategoryType.none
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
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def tag_content_tag
    Tag::Content::Tag.find_by_id(setting_value(:tag_content_tag_id))
  end

  def save_button_states
    YAML.load(setting_value(:save_button_states).presence || '[]')
  end

  def display_dates(key)
    YAML.load(setting_value(:display_dates).presence || '[]').include?(key.to_s)
  end

  def gp_calendar_content_event
    GpCalendar::Content::Event.find_by_id(setting_extra_value(:calendar_relation, :calendar_content_id))
  end

  def event_category_types
    gp_calendar_content_event.try(:category_types) || GpCategory::CategoryType.none
  end

  def event_category_type_categories_for_option(category_type, include_descendants: true)
    gp_calendar_content_event.try(:category_type_categories_for_option,
                                  category_type, include_descendants: include_descendants) || []
  end

  def calendar_related?
    setting_value('calendar_relation') == 'enabled'
  end

  def map_content_marker
    Map::Content::Marker.find_by_id(setting_extra_value(:map_relation, :map_content_id))
  end

  def marker_category_types
    map_content_marker.try(:category_types) || GpCategory::CategoryType.none
  end

  def marker_category_type_categories_for_option(category_type, include_descendants: true)
    map_content_marker.try(:category_type_categories_for_option,
                           category_type, include_descendants: include_descendants) || []
  end

  def map_related?
    setting_value('map_relation') == 'enabled'
  end

  def inquiry_related?
    setting_value('inquiry_setting') == 'enabled'
  end

  def inquiry_extra_values
    setting_extra_values('inquiry_setting').presence || GpArticle::Content::Setting.new.default_inquiry_setting
  end

  def approval_content_approval_flow
    Approval::Content::ApprovalFlow.find_by_id(setting_extra_value(:approval_relation, :approval_content_id))
  end

  def approval_related?
    setting_value('approval_relation') == 'enabled'
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title(@date @group)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
    in_settings[:display_dates] = ['published_at'] unless setting_value(:display_dates)
    in_settings[:calendar_relation] = CALENDAR_RELATION_OPTIONS.first.last unless setting_value(:calendar_relation)
    in_settings[:map_relation] = MAP_RELATION_OPTIONS.first.last unless setting_value(:map_relation)
    in_settings[:inquiry_setting] = 'enabled' unless setting_value(:inquiry_setting)
    in_settings[:approval_relation] = APPROVAL_RELATION_OPTIONS.first.last unless setting_value(:approval_relation)
  end
end
