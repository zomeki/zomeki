# encoding: utf-8
class GpCalendar::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, :name => '汎用カテゴリタイプ',
    :options => lambda { GpCategory::Content::CategoryType.all.map {|ct| [ct.name, ct.id] } }
  set_config :list_style, :name => '表示形式',
    :comment => 'タイトル：@title'
  set_config :date_style, :name => '日付形式',
    :comment => '年：%Y 月：%m 日：%d 曜日：%A 曜日（省略）：%a'
  set_config :show_images, :name => '画像表示',
    :options => GpCalendar::Event::IMAGE_STATE_OPTIONS,
    :form_type => :radio_buttons
  set_config :default_image, :name => '初期画像',
    :comment => '（例 /images/sample.jpg ）'

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

  def category_ids
    extra_values[:category_ids] || []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end
end
