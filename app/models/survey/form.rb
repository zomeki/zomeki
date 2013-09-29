class Survey::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Survey::Content::Form'
  validates_presence_of :content_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  validates :title, :presence => true

  after_initialize :set_defaults

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
  end
end
