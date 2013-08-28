# encoding: utf-8
class Rank::Content::Setting < Cms::ContentSetting
  set_config :username, :name => 'ユーザー',
    :comment => ''
  set_config :password, :name => 'パスワード',
    :form_type => :password, :comment => ''
  set_config :web_property_id, :name => 'Googleアナリティクス　トラッキングID',
    :comment => '例：UA-33912981-1'
  set_config :start_date, :name => '期間指定',
    :form_type => :date, :comment => ''
end
