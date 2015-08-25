# encoding: utf-8
class Gnav::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, name: '汎用カテゴリタイプ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map {|ct| [ct.name, ct.id] } }
  set_config :date_style, name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style').html_safe
  set_config :list_style, name: "#{GpArticle::Doc.model_name.human}表示形式",
    comment: I18n.t('comments.list_style').html_safe

  def upper_text
  end

  def lower_text
  end
end
