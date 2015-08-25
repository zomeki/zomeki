# encoding: utf-8
class Tool::ConvertImport < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  STATE_OPTIONS = [['実行中', 'process'], ['終了', 'end']]
  OVERWRITE_OPTIONS = [['更新のみ上書きする', 0], ['全て上書きする', 1]]
  KEEP_FILENAME_OPTIONS = [['ファイル名を引き継がない', 0], ['ファイル名を引き継ぐ', 1]]

  belongs_to :content, :class_name => 'Cms::Content'

  after_initialize :set_defaults

  validates :site_url, presence: true
  validates :content_id, presence: true

  def convert_setting
    return @convert_setting if @convert_setting
    @convert_setting = Tool::ConvertSetting.where(site_url: site_url).first
  end

  def doc_state
    'public'
  end

  def ignore_accessibility_check
    true
  end

  def state_label
    STATE_OPTIONS.rassoc(state).try(:first)
  end

  def overwrite_label
    OVERWRITE_OPTIONS.rassoc(overwrite).try(:first)
  end

  def keep_filename_label
    KEEP_FILENAME_OPTIONS.rassoc(keep_filename).try(:first)
  end

  def import
    update_attributes(state: 'process', start_at: Time.now)
    Tool::Convert.import_site(self)
    Tool::Convert.process_link(self, start_at)
    update_attributes(state: 'end', end_at: Time.now)
  end

  def site_filename_options
    return [] if site_url.blank?

    filenames = []
    Tool::Convert.htmlfiles(site_url, :include_child_dir => false) do |file_path, uri_path, i|
      filename = ::File.basename(file_path)
      filenames << [filename, filename]
    end
    filenames
  end

private

  def set_defaults
    self.overwrite ||= 0
    self.keep_filename ||= 0
    self.created_num ||= 0
    self.updated_num ||= 0
    self.nonupdated_num ||= 0
    self.skipped_num ||= 0
    self.link_total_num ||= 0
    self.link_processed_num ||= 0
  end
end
