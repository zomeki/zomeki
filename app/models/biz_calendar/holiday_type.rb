# encoding: utf-8
class BizCalendar::HolidayType < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'BizCalendar::Content::Place'
  validates_presence_of :content_id

  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'

  validates_presence_of :state, :name, :title
  validate :name_validity
  
  after_initialize :set_defaults

  scope :visible, where(state: 'visible')

  def state_visible?
    state == 'visible'
  end

  def name_validity
    errors.add(:name, :invalid) if self.name && self.name !~ /^[\-\w]*$/
    if (type = self.class.where(name: self.name, state: self.state, content_id: self.content.id).first)
      unless type.id == self.id
        errors.add(:name, :taken) unless state_visible?
      end
    end
  end

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_event_date'
        self.and :event_date, v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end
end