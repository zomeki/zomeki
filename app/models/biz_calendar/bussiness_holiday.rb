# encoding: utf-8
class BizCalendar::BussinessHoliday < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  REPEAT_OPTIONS = [['毎日', 'daily'], ['平日（月～金）', 'weekday'], ['土日祝日', 'saturdays'], ['祝日', 'holiday'],
    ['毎週', 'weekly'], ['毎月', 'monthly'], ['毎年', 'yearly']]

  belongs_to :status, :foreign_key => :state,    :class_name => 'Sys::Base::Status'
  belongs_to :place,  :foreign_key => :place_id, :class_name => 'BizCalendar::Place'
  belongs_to :type,   :foreign_key => :type_id,  :class_name => 'BizCalendar::HolidayType'

  validates_presence_of :state, :type_id
  validate :dates_range
  
  after_initialize :set_defaults

  scope :public, where(state: 'public')

  def self.all_with_place_and_criteria(place, criteria)
    holidays = self.arel_table

    rel = self.where(holidays[:place_id].eq(place.id))
    rel = rel.where(holidays[:repeat_type].eq(criteria[:repeat_type])) if criteria[:repeat_type].present?

    if criteria[:repeat_type].present?
      case criteria[:repeat_type]
      when ''
        rel = rel.where(holidays[:repeat_type].eq(criteria[:repeat_type]))
        if (s_ym = criteria[:start_year_month]) =~ /^(\d{6})$/ && (e_ym = criteria[:end_year_month]) =~ /^(\d{6})$/
          start_date = Date.new(s_ym.slice(0, 4).to_i, s_ym.slice(4, 2).to_i, 1)
          end_date = Date.new(e_ym.slice(0, 4).to_i, e_ym.slice(4, 2).to_i, 1)
          end_date = end_date.end_of_month
          if start_date && end_date
            rel = rel.where(holidays[:holiday_start_date].lteq(end_date)
                            .and(holidays[:holiday_end_date].gteq(start_date)))
          end
        end
      when 'not_null'
        rel = rel.where(holidays[:repeat_type].not_eq(''))
        if (s_ym = criteria[:start_year_month]) =~ /^(\d{6})$/ && (e_ym = criteria[:end_year_month]) =~ /^(\d{6})$/
          start_date = Date.new(s_ym.slice(0, 4).to_i, s_ym.slice(4, 2).to_i, 1)
          end_date = Date.new(e_ym.slice(0, 4).to_i, e_ym.slice(4, 2).to_i, 1)
          end_date = end_date.end_of_month
          if start_date && end_date
            rel = rel.where(holidays[:holiday_start_date].lteq(end_date)
                            .and(holidays[:holiday_end_date].gteq(start_date)))
          end
        end
      end
    end


    rel = case criteria[:order]
          when 'created_at_desc'
            rel.except(:order).order(holidays[:created_at].desc)
          when 'created_at_asc'
            rel.except(:order).order(holidays[:created_at].asc)
          else
            rel
          end

    return rel
  end

  def content
    place.content
  end

  def state_public?
    state == 'public'
  end

  def repeat_type_label

  end

  def holiday_date
    return '' if self.holiday_start_date.blank? && self.holiday_end_date.blank?

    if self.holiday_start_date == self.holiday_end_date
      return self.holiday_start_date.strftime("%Y-%m-%d")
    else
      return "#{self.holiday_start_date.strftime("%Y-%m-%d")} ～ #{self.holiday_end_date.strftime("%Y-%m-%d")}"
    end
  end

  def target_date_label
    if repeat_type.blank?
      self.holiday_start_date = self.holiday_end_date if self.holiday_start_date.blank?
      self.holiday_end_date = self.holiday_start_date if self.holiday_end_date.blank?

      if self.holiday_start_date == self.holiday_end_date
        return self.holiday_start_date.strftime("%Y-%m-%d")
      else
        return "#{self.holiday_start_date.strftime("%Y-%m-%d")} ～ #{self.holiday_end_date.strftime("%Y-%m-%d")}"
      end
    end
    return ''
  end

  def dates_range
    return if self.holiday_start_date.blank? && self.holiday_end_date.blank?
    self.holiday_start_date = self.holiday_end_date if self.holiday_start_date.blank?
    self.holiday_end_date = self.holiday_start_date if self.holiday_end_date.blank?
    errors.add(:holiday_end_date, "が#{self.class.human_attribute_name :holiday_start_date}を過ぎています。") if self.holiday_end_date < self.holiday_start_date
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