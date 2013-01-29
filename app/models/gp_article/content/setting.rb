# encoding: utf-8
class GpArticle::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, :name => '汎用カテゴリタイプ',
    :options => lambda { GpCategory::Content::CategoryType.all.map {|ct| [ct.name, ct.id] } }
  set_config :allowed_attachment_type, :name => '添付ファイル/許可する種類',
    :comment => '（例 gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp ）'
  set_config :recognition_type, :name => '承認/承認フロー',
    :options => [['管理者承認が必要', 'with_admin']]
  set_config :list_style, :name => "#{GpArticle::Doc.model_name.human}表示形式",
    :comment => '日付：@date タイトル：@title 組織：@group カテゴリ：@category'
  set_config :date_style, :name => "#{GpArticle::Doc.model_name.human}日付形式",
    :comment => '年：%Y 月：%m 日：%d 時：%H 分：%M 秒：%S'

  after_initialize :set_defaults

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

  private

  def set_defaults
    self.value = '@title(@date @group)' if self.name == 'list_style' && self.value.nil?
    self.value = '%Y年%m月%d日 %H時%M分' if self.name == 'date_style' && self.value.nil?
  rescue ActiveModel::MissingAttributeError => evar
    logger.warn(evar.message)
  end
end
