module GpCalendar::EventSync
  extend ActiveSupport::Concern

  WILL_SYNC_OPTIONS = [['同期する', 'enabled'], ['同期しない', 'disabled']]

  included do
  end

  def will_sync?
    return false unless respond_to?(:will_sync)
    will_sync == 'enabled'
  end

  def will_sync_text
    return '' unless respond_to?(:will_sync)
    WILL_SYNC_OPTIONS.detect{|o| o.last == will_sync }.try(:first).to_s
  end
end
