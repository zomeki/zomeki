# encoding: utf-8
class GpArticle::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, :name => '汎用カテゴリタイプ',
    :options => lambda { GpCategory::Content::CategoryType.all.map {|ct| [ct.name, ct.id] } }
  set_config :allowed_attachment_type, :name => '添付ファイル/許可する種類',
    :comment => '（例 gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp ）'
  set_config :recognition_type, :name => '承認/承認フロー',
    :options => [['管理者承認が必要', 'with_admin']]
  set_config :required_recognizers, :name => '承認/必須承認者',
    :form_type => :multiple_select,
    :options => lambda { Sys::User }
  set_config :list_style, :name => "#{GpArticle::Doc.model_name.human}表示形式",
    :comment => '日付：@date タイトル：@title 組織：@group カテゴリ：@category'
  set_config :date_style, :name => "#{GpArticle::Doc.model_name.human}日付形式",
    :comment => '年：%Y 月：%m 日：%d 時：%H 分：%M 秒：%S'
  set_config :gp_calendar_content_event_id, :name => '汎用カレンダー',
    :options => lambda { GpCalendar::Content::Event.all.map {|e| [e.name, e.id] } }
  set_config :tag_content_tag_id, :name => '関連ワード',
    :options => lambda { Tag::Content::Tag.all.map {|t| [t.name, t.id] } }
  set_config :save_button_states, :name => '保存ボタン',
#TODO: 暫定として即時公開のみ
    :options => GpArticle::Doc::STATE_OPTIONS.reject {|o| o.last != 'public' },
#    :options => GpArticle::Doc::STATE_OPTIONS,
    :form_type => :check_boxes
  set_config :map_content_marker_id, :name => 'マップ',
    :options => lambda { Map::Content::Marker.all.map {|m| [m.name, m.id] } }

  def upper_text
  end

  def lower_text
  end

  def extra_values=(ev)
    self.extra_value = YAML.dump(ev) if ev.is_a?(Hash)
    return ev
  end

  def extra_values
    return {}.with_indifferent_access unless self.extra_value.is_a?(String)
    ev = YAML.load(self.extra_value)
    return {}.with_indifferent_access unless ev.is_a?(Hash)
    return ev.with_indifferent_access
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
end
