# encoding: utf-8
class Tag::Content::Setting < Cms::ContentSetting
  set_config :date_style, :name => "#{GpArticle::Doc.model_name.human}日付形式",
    :comment => I18n.t('comments.date_style').html_safe
  set_config :list_style, :name => "#{GpArticle::Doc.model_name.human}表示形式",
    :comment => I18n.t('comments.list_style').html_safe

  def upper_text
  end

  def lower_text
  end
end
