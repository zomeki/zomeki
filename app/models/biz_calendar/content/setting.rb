# encoding: utf-8
class BizCalendar::Content::Setting < Cms::ContentSetting
  set_config :month_number, :name => "index表示月数"
  set_config :show_month_number, :name => "拠点表示月数"
  
end