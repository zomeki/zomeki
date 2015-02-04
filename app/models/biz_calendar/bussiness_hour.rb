# encoding: utf-8
class BizCalendar::BussinessHour < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  REPEAT_OPTIONS = [['毎日', 'daily'], ['平日（月～金）', 'weekday'], ['土日祝日', 'saturdays'], ['祝日', 'holiday'],
    ['毎週', 'weekly'], ['毎月', 'monthly'], ['毎年', 'yearly']]

  belongs_to :status, :foreign_key => :state,    :class_name => 'Sys::Base::Status'
  belongs_to :place,  :foreign_key => :place_id, :class_name => 'BizCalendar::Place'

  validates_presence_of :state, :business_hours_start_time, :business_hours_end_time
  validate :dates_range
  
  after_initialize :set_defaults

  scope :public, where(state: 'public')

  def content
    place.content
  end

  def state_public?
    state == 'public'
  end

  def repeat_type_label

  end
  
  def fixed_date
    return '' if self.fixed_start_date.blank? && self.fixed_end_date.blank?

    if self.fixed_start_date == self.fixed_end_date
      return self.fixed_start_date.strftime("%Y-%m-%d")
    else
      return "#{self.fixed_start_date.strftime("%Y-%m-%d")} ～ #{self.fixed_end_date.strftime("%Y-%m-%d")}"
    end
  end

  def target_date_label
    if repeat_type.blank?
      self.fixed_start_date = self.fixed_end_date if self.fixed_start_date.blank?
      self.fixed_end_date = self.fixed_start_date if self.fixed_end_date.blank?

      if self.fixed_start_date == self.fixed_end_date
        return self.fixed_start_date.strftime("%Y-%m-%d")
      else
        return "#{self.fixed_start_date.strftime("%Y-%m-%d")} ～ #{self.fixed_end_date.strftime("%Y-%m-%d")}"
      end
    end
    return ''
  end

  def dates_range
    return if self.fixed_start_date.blank? && self.fixed_end_date.blank?
    self.fixed_start_date = self.fixed_end_date if self.fixed_start_date.blank?
    self.fixed_end_date = self.fixed_start_date if self.fixed_end_date.blank?
    errors.add(:fixed_end_date, "が#{self.class.human_attribute_name :fixed_start_date}を過ぎています。") if self.fixed_end_date < self.fixed_start_date
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