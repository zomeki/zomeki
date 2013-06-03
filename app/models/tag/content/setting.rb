# encoding: utf-8
class Tag::Content::Setting < Cms::ContentSetting
  set_config :list_style, :name => "#{GpArticle::Doc.model_name.human}表示形式",
    :comment => '日付：@date タイトル：@title 組織：@group カテゴリ：@category'
  set_config :date_style, :name => "#{GpArticle::Doc.model_name.human}日付形式",
    :comment => '年：%Y 月：%m 日：%d 時：%H 分：%M 秒：%S'

  def upper_text
  end

  def lower_text
  end
end
