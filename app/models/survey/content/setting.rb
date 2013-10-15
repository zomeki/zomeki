# encoding: utf-8
class Survey::Content::Setting < Cms::ContentSetting
  set_config :mail_from, :name => '差出人メールアドレス'
  set_config :mail_to, :name => '通知先メールアドレス'

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
