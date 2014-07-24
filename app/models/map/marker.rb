# encoding: utf-8
class Map::Marker < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::File
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Map::Content::Marker'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_many :categorizations, :class_name => 'GpCategory::Categorization', :as => :categorizable, :dependent => :destroy
  has_many :categories, :class_name => 'GpCategory::Category', :through => :categorizations

  validates :title, :presence => true
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true

  after_initialize :set_defaults
  before_save :set_name

  scope :public, where(state: 'public')

  belongs_to :icon_category, :class_name => 'GpCategory::Category'
  belongs_to :doc, :class_name => 'GpArticle::Doc' # Not saved to database

  def public_uri
    return '' unless content.public_node
    "#{content.public_node.public_uri}#{name}/"
  end

  def public_file_uri
    return '' if public_uri.blank? || files.empty?
    "#{public_uri}file_contents/#{files.first.name}"
  end

  def public_path
    return '' unless content.public_node
    "#{content.public_node.public_path}#{name}/"
  end

  def public_file_path
    return '' if public_path.blank? || files.empty?
    "#{public_path}file_contents/#{files.first.name}"
  end

  def public_smart_phone_path
    return '' unless content.public_node
    "#{content.public_node.public_smart_phone_path}#{name}/"
  end

  def public_smart_phone_file_path
    return '' if public_smart_phone_path.blank? || files.empty?
    "#{public_smart_phone_path}file_contents/#{files.first.name}"
  end

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.target ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
  end

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('map_markers', :version => date)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end
end
