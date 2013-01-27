# encoding: utf-8
class GpArticle::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, :name => '汎用カテゴリタイプ',
    :options => GpCategory::Content::CategoryType.all.map{|ct| [ct.name, ct.id] }
  set_config :allowed_attachment_type, :name => '添付ファイル/許可する種類',
    :comment => '（例 gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp ）'
  set_config :recognition_type, :name => '承認/承認フロー',
    :options => [['管理者承認が必要', 'with_admin']]

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
end
