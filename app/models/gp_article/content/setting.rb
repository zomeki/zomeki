# encoding: utf-8
class GpArticle::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, name: '汎用カテゴリタイプ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map {|ct| [ct.name, ct.id] } }
  set_config :basic_setting, name: '基本設定',
    form_type: :select_with_tree, lower_text: "未設定の場合、記事ディレクトリの設定が記事へ反映されます"
  set_config :gp_template_content_template_id, name: 'テンプレート',
    options: lambda { GpTemplate::Content::Template.where(site_id: Core.site.id).map {|t| [t.name, t.id] } }
  set_config :allowed_attachment_type, name: '添付ファイル/許可する種類',
    comment: '（例 gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp ）'
  set_config :word_dictionary, name: "本文/単語変換辞書",
    form_type: :text, lower_text: "CSV形式（例　対象文字,変換後文字 ）"
  set_config :doc_list_style, name: "#{GpArticle::Doc.model_name.human}一覧表示形式",
    options: GpArticle::Content::Doc::DOC_LIST_STYLE_OPTIONS
  set_config :list_style, name: "#{GpArticle::Doc.model_name.human}表示形式",
    form_type: :text_area, comment_upper: 'doc_style_tags'
  set_config :rel_docs_style, name: "関連#{GpArticle::Doc.model_name.human}表示形式",
    form_type: :text_area, comment_upper: 'doc_style_tags'
  set_config :date_style, name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style').html_safe
  set_config :time_style, name: "#{GpArticle::Doc.model_name.human}時間形式",
    comment: I18n.t('comments.time_style').html_safe
  set_config :feed, name: "フィード",
    options: GpArticle::Content::Doc::FEED_DISPLAY_OPTIONS,
    form_type: :radio_buttons
  set_config :calendar_relation, name: '汎用カレンダー',
    options: GpArticle::Content::Doc::CALENDAR_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :tag_relation, name: '関連ワード',
    options: GpArticle::Content::Doc::TAG_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :save_button_states, name: '保存ボタン',
#TODO: 暫定として即時公開のみ
    options: GpArticle::Doc::STATE_OPTIONS.reject {|o| o.last != 'public' },
#    options: GpArticle::Doc::STATE_OPTIONS,
    form_type: :check_boxes
  set_config :map_relation, name: 'マップ',
    options: GpArticle::Content::Doc::MAP_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :display_dates, name: '記事日付表示',
    options: [['公開日', 'published_at'], ['最終更新日', 'updated_at']],
    form_type: :check_boxes
  set_config :inquiry_setting, name: '連絡先',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    form_type: :radio_buttons
  set_config :approval_relation, name: '承認フロー',
    options: GpArticle::Content::Doc::APPROVAL_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :sns_share_relation, name: 'SNSシェア',
    options: GpArticle::Content::Doc::SNS_SHARE_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :blog_functions, name: 'ブログ',
    options: GpArticle::Content::Doc::BLOG_FUNCTIONS_OPTIONS,
    form_type: :radio_buttons
  set_config :organization_content_group_id, name: '組織',
    options: lambda { Organization::Content::Group.where(site_id: Core.site.id).map{|g| [g.name, g.id] } }
  set_config :broken_link_notification, name: 'リンク切れ通知',
    options: GpArticle::Content::Doc::BROKEN_LINK_NOTIFICATION_OPTIONS,
    form_type: :radio_buttons
  set_config :feature_settings, name: '記事表示設定',
    options: GpArticle::Content::Doc::FEATURE_SETTINGS_OPTIONS,
    form_type: :radio_buttons
  set_config :qrcode_settings, name: 'QRコード',
    options: GpArticle::Content::Doc::QRCODE_SETTINGS_OPTIONS,
    form_type: :radio_buttons

  after_initialize :set_defaults

  def content
    GpArticle::Content::Doc.find(content_id)
  end

  def upper_text
    config[:upper_text].to_s
  end

  def lower_text
    config[:lower_text].to_s
  end

  def category_type_ids
    extra_values[:category_type_ids] || []
  end

  def visible_category_type_ids
    extra_values[:visible_category_type_ids] || []
  end

  def default_category_type_id
    extra_values[:default_category_type_id] || 0
  end

  def default_category_id
    extra_values[:default_category_id] || 0
  end

  def template_ids
    extra_values[:template_ids] || []
  end

  def default_template_id
    extra_values[:default_template_id] || 0
  end

  def default_inquiry_setting
    {
      display_fields: ['group_id', 'address', 'tel', 'fax', 'email', 'note']
    }
  end

  def default_layout_id
    extra_values[:default_layout_id] || 0
  end

  def config_options
    case name
    when 'basic_setting'
      return {
        :root => Cms::Concept.where(site_id: Core.site.id, parent_id: 0, level_no: 1, state: 'public'),
        :configs => {:conditions => {:state => 'public'}, :include_blank => true}
      }
    end
    super
  end

  private

  def set_defaults
    case name
    when 'inquiry_setting'
      self.value = 'enabled' if value.blank?
      self.extra_values = default_inquiry_setting if extra_values.blank?
    when 'feed'
      self.value = 'enabled' if value.blank?
      self.extra_values = { feed_docs_number: '10' } if extra_values.blank?
    when 'blog_functions'
      ev = self.extra_values
      ev[:footer_style] = '投稿者：@user@ @publish_time@ コメント(@comment_count@) カテゴリ：@category_link@' if ev[:footer_style].nil?
      self.extra_values = ev
    when 'qrcode_settings'
      self.value = 'disabled' if value.blank?
      self.extra_values = { state: 'hidden' } if extra_values.blank?
    end
  end
end
