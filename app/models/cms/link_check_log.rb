class Cms::LinkCheckLog < ActiveRecord::Base
  include Sys::Model::Base

  attr_accessible :link_checkable, :title, :body, :url

  belongs_to :link_check
  belongs_to :link_checkable, :polymorphic => true

  after_initialize :set_defaults

  scope :none, where('id IS ?', nil).where('id IS NOT ?', nil)

  private

  def set_defaults
    self.checked = false if self.has_attribute?(:checked) && self.checked.nil?
  end
end
