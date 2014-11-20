# encoding: utf-8
class Sys::Setting < Sys::Model::Base::Setting
  include Sys::Model::Base

  set_config :common_ssl, :name => "共有SSL", :default => 'disabled',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    form_type: :radio_buttons
  set_config :pass_reminder_mail_sender, :name => "パスワード変更メール送信元アドレス", :default => 'noreply'
  set_config :file_upload_max_size, :name => "添付ファイル最大サイズ", :comment => 'MB', :default => 50

  validates_presence_of :name

  def self.use_common_ssl?
    return false if Sys::Setting.value(:common_ssl) != 'enabled'
    return false if Sys::Setting.setting_extra_value(:common_ssl, :common_ssl_uri).blank?
    return true
  end

end
