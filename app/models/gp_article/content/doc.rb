# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  CALENDAR_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  MAP_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  APPROVAL_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  INQUIRY_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  INQUIRY_FIELD_OPTIONS = [['住所', 'address'], ['TEL', 'tel'], ['FAX', 'fax'], ['メールアドレス', 'email'], ['備考', 'note']] # ['課', 'group_id'], ['室・担当', 'charge'],
  FEED_DISPLAY_OPTIONS = [['表示する', 'enabled'], ['表示しない', 'disabled']]
  TAG_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  SNS_SHARE_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  BLOG_FUNCTIONS_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  BROKEN_LINK_NOTIFICATION_OPTIONS = [['通知する', 'enabled'], ['通知しない', 'disabled']]
  FEATURE_SETTINGS_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  WRAPPER_TAG_OPTIONS = [['li', 'li'], ['article', 'article']]
  DOC_LIST_STYLE_OPTIONS = [['日付毎', 'by_date'], ['記事一覧', 'simple']]
  QRCODE_SETTINGS_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  QRCODE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  EVENT_SYNC_SETTINGS_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  EVENT_SYNC_DEFAULT_WILL_SYNC_OPTIONS = [['同期する', 'enabled'], ['同期しない', 'disabled']]

  default_scope { where(model: 'GpArticle::Doc') }

  has_many :docs, :foreign_key => :content_id, :class_name => 'GpArticle::Doc', :dependent => :destroy

  before_create :set_default_settings

  # draft, approvable, approved, public, closed, archived
  def all_docs
    docs.unscoped.where(content_id: id).mobile(::Page.mobile?)
  end

  # draft, approvable, approved, public
  def preview_docs
    table = docs.arel_table
    docs.mobile(::Page.mobile?).where(table[:state].not_eq('closed'))
  end

  # public
  def public_docs
    docs.mobile(::Page.mobile?).public
  end

  def public_node
    Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Doc').order(:id).first
  end

  def public_archives_node
    Cms::Node.where(state: 'public', content_id: id, model: 'GpArticle::Archive').order(:id).first
  end

  def public_nodes
    Cms::Node.public.where(content_id: id)
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

  def time_style
    setting_value(:time_style).to_s
  end

  def tag_related?
    setting_value(:tag_relation) == 'enabled'
  end

  def tag_content_tag
    Tag::Content::Tag.find_by_id(setting_extra_value(:tag_relation, :tag_content_tag_id))
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
    setting_value(:calendar_relation) == 'enabled'
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

  def marker_icon_category_enabled?
    setting_extra_value(:map_relation, :marker_icon_category) == 'enabled'
  end

  def map_related?
    setting_value(:map_relation) == 'enabled'
  end

  def inquiry_related?
    setting_value(:inquiry_setting) == 'enabled'
  end

  def inquiry_extra_values
    setting_extra_values('inquiry_setting').presence || GpArticle::Content::Setting.new.default_inquiry_setting
  end

  def approval_content_approval_flow
    Approval::Content::ApprovalFlow.find_by_id(setting_extra_value(:approval_relation, :approval_content_id))
  end

  def approval_related?
    setting_value(:approval_relation) == 'enabled'
  end

  def sns_share_content_account
    SnsShare::Content::Account.find_by_id(setting_extra_value(:sns_share_relation, :sns_share_content_id))
  end

  def sns_share_related?
    setting_value(:sns_share_relation) == 'enabled'
  end

  def template_available?
    gp_temlate_content_template.present? && templates.present?
  end

  def gp_temlate_content_template
    return nil if setting_value(:gp_template_content_template_id).blank?
    GpTemplate::Content::Template.where(id: setting_value(:gp_template_content_template_id)).first
  end

  def templates
    return GpTemplate::Template.none if setting_value(:gp_template_content_template_id).blank?
    GpTemplate::Template.where(id: setting_extra_value(:gp_template_content_template_id, :template_ids))
  end

  def default_template
    return nil if setting_value(:gp_template_content_template_id).blank?
    GpTemplate::Template.where(id: setting_extra_value(:gp_template_content_template_id, :default_template_id)).first
  end

  def feed_display?
    setting_value(:feed) != 'disabled'
  end

  def feed_docs_number
    (setting_extra_value(:feed, :feed_docs_number).presence || 10).to_i
  end

  def feed_docs_period
    setting_extra_value(:feed, :feed_docs_period)
  end

  def blog_functions_available?
    setting_value(:blog_functions) == 'enabled'
  end

  def blog_functions
    {comment: setting_extra_value(:blog_functions, :comment) == 'enabled',
     comment_open: setting_extra_value(:blog_functions, :comment_open) == 'immediate',
     comment_notification_mail: setting_extra_value(:blog_functions, :comment_notification_mail) == 'enabled',
     footer_style: setting_extra_value(:blog_functions, :footer_style).to_s}
  end

  def comments
    rel = GpArticle::Comment.joins(:doc)

    docs = GpArticle::Doc.arel_table
    rel = rel.where(docs[:content_id].eq(self.id))

    return rel
  end

  def public_comments
    docs = GpArticle::Doc.arel_table
    comments.where(docs[:state].eq('public')).public
  end

  def organization_content_group
    Organization::Content::Group.find_by_id(setting_value(:organization_content_group_id))
  end

  def notify_broken_link?
    setting_value(:broken_link_notification) == 'enabled'
  end

  def rewrite_configs
    if node = public_node
      []
    else
      []
    end
  end

  def public_path
    site.public_path
  end

  def feature_settings_enabled?
    setting_value(:feature_settings) == 'enabled'
  end

  def feature_settings
    {feature_1: setting_extra_value(:feature_settings, :feature_1) != 'false',
     feature_2: setting_extra_value(:feature_settings, :feature_2) != 'false'}
  end

  def wrapper_tag
    setting_extra_value(:list_style, :wrapper_tag) || WRAPPER_TAG_OPTIONS.first.last
  end

  def doc_list_style
    setting_value(:doc_list_style).to_s
  end

  def rel_docs_style
    setting_value(:rel_docs_style).to_s
  end

  def qrcode_related?
    setting_value(:qrcode_settings) == 'enabled'
  end

  def qrcode_default_state
    setting_extra_value(:qrcode_settings, :state) || QRCODE_STATE_OPTIONS.last.last
  end

  def event_sync?
    setting_extra_value(:calendar_relation, :event_sync_settings) == 'enabled'
  end

  def event_sync_default_will_sync
    setting_extra_value(:calendar_relation, :event_sync_default_will_sync).to_s
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title_link@(@publish_date@ @group@)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
    in_settings[:time_style] = '%H時%M分' unless setting_value(:time_style)
    in_settings[:display_dates] = ['published_at'] unless setting_value(:display_dates)
    in_settings[:calendar_relation] = CALENDAR_RELATION_OPTIONS.first.last unless setting_value(:calendar_relation)
    in_settings[:map_relation] = MAP_RELATION_OPTIONS.first.last unless setting_value(:map_relation)
    in_settings[:inquiry_setting] = 'enabled' unless setting_value(:inquiry_setting)
    in_settings[:approval_relation] = APPROVAL_RELATION_OPTIONS.first.last unless setting_value(:approval_relation)
    in_settings[:feed] = FEED_DISPLAY_OPTIONS.first.last unless setting_value(:feed)
    in_settings[:tag_relation] = TAG_RELATION_OPTIONS.first.last unless setting_value(:tag_relation)
    in_settings[:sns_share_relation] = SNS_SHARE_RELATION_OPTIONS.first.last unless setting_value(:sns_share_relation)
    in_settings[:blog_functions] = BLOG_FUNCTIONS_OPTIONS.last.last unless setting_value(:blog_functions)
    in_settings[:broken_link_notification] = BROKEN_LINK_NOTIFICATION_OPTIONS.first.last unless setting_value(:broken_link_notification)
    in_settings[:feature_settings] = FEATURE_SETTINGS_OPTIONS.last.last unless setting_value(:feature_settings)
    in_settings[:doc_list_style] = DOC_LIST_STYLE_OPTIONS.first.last unless setting_value(:doc_list_style)
  end
end
