# encoding: utf-8
class GpArticle::Content::Setting < Cms::ContentSetting
  set_config :gp_category_category_type_content_id, :name => '汎用カテゴリタイプ',
    :options => Cms::Content.where(model: 'GpCategory::CategoryType').map{|ct| [ct.name, ct.id] }

  def upper_text
  end

  def lower_text
  end
end
