class Organization::Group < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  attr_accessible :state, :name, :sys_group_code, :sitemap_state, :docs_order, :sort_no

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'display_published_at DESC, published_at DESC'],
                        ['公開日（昇順）', 'display_published_at ASC, published_at ASC']]

  default_scope order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no")

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Organization::Content::Group'
  validates_presence_of :content_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  belongs_to :sys_group, :foreign_key => :sys_group_code, :primary_key => :code, :class_name => 'Sys::Group'

  after_initialize :set_defaults

  validates :name, :presence => true, :uniqueness => true
  validates :sys_group_code, :presence => true, :uniqueness => true

  def sitemap_state_text
    SITEMAP_STATE_OPTIONS.detect{|o| o.last == self.sitemap_state }.try(:first).to_s
  end

  def docs_order_text
    DOCS_ORDER_OPTIONS.detect{|o| o.last == self.docs_order }.try(:first).to_s
  end

  private

  def set_defaults
    self.state = STATE_OPTIONS.first.last if self.has_attribute?(:state) && self.state.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.docs_order = DOCS_ORDER_OPTIONS.first.last if self.has_attribute?(:docs_order) && self.docs_order.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
