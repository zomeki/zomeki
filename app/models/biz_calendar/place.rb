# encoding: utf-8
class BizCalendar::Place < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  BUSINESS_HOURS_STATE_OPTIONS = [['表示する','visible'],['表示しない','hidden']]
  BUSINESS_HOLIDAY_STATE_OPTIONS = [['表示する','visible'],['表示しない','hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'BizCalendar::Content::Place'
  validates_presence_of :content_id

  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'

  has_many :hours,              :class_name => 'BizCalendar::BussinessHour',    :dependent => :destroy
  has_many :holidays,           :class_name => 'BizCalendar::BussinessHoliday', :dependent => :destroy
  has_many :exception_holidays, :class_name => 'BizCalendar::ExceptionHoliday', :dependent => :destroy

  validates_presence_of :state, :url, :title
  validate :url_validity
  
  after_initialize :set_defaults

  scope :public, where(state: 'public')

  def state_public?
    state == 'public'
  end

  def public_uri
    return '' unless node = content.public_node
    "#{node.public_uri}#{url}/"
  end

  def url_validity
    errors.add(:url, :invalid) if self.url && self.url !~ /^[\-\w]*$/
    if (doc = self.class.where(url: self.url, state: self.state, content_id: self.content.id).first)
      unless doc.id == self.id
        errors.add(:url, :taken) unless state_public?
      end
    end
  end

  def set_defaults
    self.state                  ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.business_hours_state   ||= BUSINESS_HOURS_STATE_OPTIONS.last.last if self.has_attribute?(:business_hours_state)
    self.business_holiday_state ||= BUSINESS_HOLIDAY_STATE_OPTIONS.last.last if self.has_attribute?(:business_holiday_state)
    self.sort_no                ||= 10 if self.has_attribute?(:sort_no)
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