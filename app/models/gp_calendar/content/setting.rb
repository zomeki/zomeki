# encoding: utf-8
class GpCalendar::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, name: '汎用カテゴリタイプ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map {|ct| [ct.name, ct.id] } }
  set_config :date_style, name: '日付形式',
    comment: '<strong>年：</strong>%Y <strong>月：</strong>%m <strong>日：</strong>%d <strong>曜日：</strong>%A <strong>曜日（省略）：</strong>%a'.html_safe
  set_config :list_style, name: '表示形式',
    comment: '<strong>タイトル：</strong>@title_link@'.html_safe
  set_config :show_images, name: '画像表示',
    options: GpCalendar::Content::Event::IMAGE_STATE_OPTIONS,
    form_type: :radio_buttons
  set_config :default_image, name: '初期画像',
    comment: '（例 /images/sample.jpg ）'
  set_config :show_qreki, name: '旧暦表示',
    options: [["表示する", 1], ["表示しない", 0]]
  set_config :event_sync_import, name: 'イベント同期（インポート）',
    options: GpCalendar::Content::Event::EVENT_SYNC_OPTIONS
  set_config :event_sync_export, name: 'イベント同期（エクスポート）',
    options: GpCalendar::Content::Event::EVENT_SYNC_OPTIONS

  def upper_text
  end

  def lower_text
  end

  def category_ids
    extra_values[:category_ids] || []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end
end
