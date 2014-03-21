class Cms::LinkCheckLog < ActiveRecord::Base
  include Sys::Model::Base

  attr_accessible :link_checkable, :title, :body, :url

  belongs_to :link_check
  belongs_to :link_checkable, :polymorphic => true

  after_initialize :set_defaults

  scope :none, -> { where("#{self.table_name}.id IS ?", nil).where("#{self.table_name}.id IS NOT ?", nil) }

  scope :site, -> { where("#{self.table_name}.id IS ?", nil).where("#{self.table_name}.id IS NOT ?", nil) }

  def site_id
    link_checkable.content.site_id
  end

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end
end
