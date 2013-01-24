# encoding: utf-8
class GpCategory::Content::Setting < Cms::ContentSetting
  set_config :group_category_type_name, :name => "組織用#{GpCategory::CategoryType.human_attribute_name :name}",
    :comment => '初期値 ： groups'

  def upper_text
  end

  def lower_text
  end
end
