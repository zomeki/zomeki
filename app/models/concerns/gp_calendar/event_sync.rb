module GpCalendar::EventSync
  extend ActiveSupport::Concern

  WILL_SYNC_OPTIONS = [['同期しない', 'no'], ['同期する', 'yes']]

  included do
  end

  def will_sync?
    return false unless respond_to?(:will_sync)
    will_sync == 'yes'
  end

  def will_sync_text
    return '' unless respond_to?(:will_sync)
    WILL_SYNC_OPTIONS.detect{|o| o.last == will_sync }.try(:first).to_s
  end

  def sync_exported?
    return false unless respond_to?(:sync_exported)
    sync_exported == 'yes'
  end

  def sync_exported_text
    return '' unless respond_to?(:sync_exported)
    sync_exported? ? '同期済' : '未同期'
  end
end
