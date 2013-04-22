# encoding: utf-8
class Map::Marker < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Auth::Free

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Map::Content::Marker'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  validates :title, :presence => true
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true

  after_initialize :set_defaults

  scope :public, where(state: 'public')

  belongs_to :doc, :class_name => 'GpArticle::Doc' # Not saved to database

  private

  def set_defaults
    self.state ||= 'public' if self.has_attribute?(:state)
  end
end
