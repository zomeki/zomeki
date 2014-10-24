# encoding: utf-8
class Survey::Content::Setting < Cms::ContentSetting
  set_config :mail_from, :name => '差出人メールアドレス'
  set_config :mail_to, :name => '通知先メールアドレス'
  set_config :approval_relation, :name => '承認フロー',
    :options => Survey::Content::Form::APPROVAL_RELATION_OPTIONS,
    :form_type => :radio_buttons
  set_config :captcha, :name => '画像認証',
    :options => Survey::Content::Form::CAPTCHA_OPTIONS
  set_config :common_ssl, :name => '共有SSL',
    :options => Survey::Content::Form::SSL_OPTIONS,
    :form_type => :radio_buttons
  set_config :auto_reply, :name => "自動返信",
    :options => [['返信する','send'],['返信しない','none']]
  set_config :upper_reply_text, :name => "自動返信テキスト（上部）",
    :form_type => :text
  set_config :lower_reply_text, :name => "自動返信テキスト（下部）",
    :form_type => :text

  validate :validate_value

  def upper_text
  end

  def lower_text
  end

  private

  def validate_value
    case name
    when 'mail_from', 'mail_to'
      errors.add :value, :blank if value.blank?
    end
  end
end
