# encoding: utf-8
class GpCalendar::Holiday < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  KIND_OPTIONS = [['休日', 'holiday'], ['イベント', 'event']]
  ORDER_OPTIONS = [['作成日時（降順）', 'created_at_desc'], ['作成日時（昇順）', 'created_at_asc']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  after_initialize :set_defaults

  validates_presence_of :name, :date

  scope :public, where(state: 'public')

  belongs_to :doc, :class_name => 'GpArticle::Doc' # Not saved to database

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
  end

end
