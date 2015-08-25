# encoding: utf-8
class Rank::Content::Setting < Cms::ContentSetting
  set_config :web_property_id, name: 'Googleアナリティクス　トラッキングID', comment: '例：UA-33912981-1'
  set_config :show_count,      name: 'アクセス数の表示', options: [['表示する', 1], ['表示しない', 0]]
  set_config :exclusion_url,   name: '除外URL', lower_text: 'スペースまたは改行で複数指定できます。', form_type: :text
  set_config :google_oauth,    name: 'Google OAuth'
end
