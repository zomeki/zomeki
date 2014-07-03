# encoding: utf-8
class Tool::ConvertDownload < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  STATE_OPTIONS = [['実行中', 'process'], ['終了', 'end']]

  validates :site_url, presence: true

  def state_label
    STATE_OPTIONS.rassoc(state).try(:first)
  end

  def download
    update_attributes(state: 'process', start_at: Time.now)
    Tool::Convert.download_site(self)
    update_attributes(state: 'end', end_at: Time.now)
  end
end
