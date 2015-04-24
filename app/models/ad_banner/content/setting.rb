# encoding: utf-8
class AdBanner::Content::Setting < Cms::ContentSetting
  set_config :click_count_setting, name: 'クリック数カウント',
    options: [['有効', 'enabled'], ['無効', 'disabled']],
    form_type: :radio_buttons

  after_initialize :set_defaults

  def content
    AdBanner::Content::Banner.find(content_id)
  end

  private

  def set_defaults
    case name
    when 'click_count_setting'
      self.value = 'enabled' if value.blank?
    end
  end
end
