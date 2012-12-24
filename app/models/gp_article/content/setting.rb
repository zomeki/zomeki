# encoding: utf-8
class GpArticle::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, :name => '汎用カテゴリタイプ',
    :options => GpCategory::Content::CategoryType.all.map{|ct| [ct.name, ct.id] }
  set_config :allowed_attachment_type, :name => '添付ファイル/許可する種類',
    :comment => '（例 gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp ）'

  def upper_text
  end

  def lower_text
  end
end
