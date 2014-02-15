# encoding: utf-8
class Rank::Content::Setting < Cms::ContentSetting
  set_config :username,        name: 'ユーザー'
  set_config :password,        name: 'パスワード', form_type: :password
  set_config :web_property_id, name: 'Googleアナリティクス　トラッキングID', comment: '例：UA-33912981-1'
  set_config :show_count,      name: 'アクセス数の表示', options: [['表示する', 1], ['表示しない', 0]]
  set_config :exclusion_url,   name: '除外URL', lower_text: 'スペースまたは改行で複数指定できます。'
  set_config :category_option, name: 'カテゴリ別ランキング', form_type: :radio_buttons, options: [['表示する', 'on'], ['表示しない', 'off']]

  def value_name
    unless value.blank?
      case name
      when 'category_option'
        config_options.each { |opt| return opt.first if opt.last == value }
      end
    end
    super
  end
end
