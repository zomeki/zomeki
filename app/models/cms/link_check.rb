class Cms::LinkCheck < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order("#{self.table_name}.id DESC")

  has_many :logs, class_name: 'Cms::LinkCheckLog', :dependent => :destroy

  after_initialize :set_defaults

  def execute
    update_column(:in_progress, true)

    logs.where(checked: false).each do |log|
      res = Util::LinkChecker.check_url(log.url)
      log.status = res[:status]
      log.reason = res[:reason]
      log.result = res[:result]
      log.checked = true
      log.save

      break unless reload.in_progress
    end

    transaction do
      update_column(:checked, logs.all?{|l| l.checked })
      update_column(:in_progress, false)
    end
  end

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end
end
