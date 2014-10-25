# encoding: utf-8
class GpTemplate::Template < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  default_scope { order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no") }

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpTemplate::Content::Template'
  validates_presence_of :content_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  has_many :items, :dependent => :destroy

  validates :title, :presence => true

  after_initialize :set_defaults

  scope :public, -> { where(state: 'public') }
  scope :none, -> { where("#{self.table_name}.id IS ?", nil).where("#{self.table_name}.id IS NOT ?", nil) }

  def public_items
    items.public
  end

  def state_public?
    state == 'public'
  end

  def duplicate
    item = self.class.new(self.attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil

    item.title = item.title.gsub(/^(【複製】)*/, "【複製】")

    return false unless item.save(:validate => false)

    # piece_settings
    items.each do |i|
      dupe_item = GpTemplate::Item.new(i.attributes)
      dupe_item.template_id = item.id
      dupe_item.created_at  = nil
      dupe_item.updated_at  = nil
      dupe_item.save(:validate => false)
    end

    return item
  end

  private

  def set_defaults
    self.state   = STATE_OPTIONS.first.last if self.has_attribute?(:state) && self.state.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
