# encoding: utf-8
class BizCalendar::BussinessHoliday < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  REPEAT_OPTIONS = [['毎日', 'daily'], ['平日（月～金）', 'weekday'], ['土日祝日', 'saturdays'], ['祝日', 'holiday'],
    ['毎週', 'weekly'], ['毎月', 'monthly'], ['毎年', 'yearly']]
  END_TYPE_OPTIONS = [['なし', 0], ['回数指定', 1], ['日指定', 2]]

  belongs_to :status, :foreign_key => :state,    :class_name => 'Sys::Base::Status'
  belongs_to :place,  :foreign_key => :place_id, :class_name => 'BizCalendar::Place'
  belongs_to :type,   :foreign_key => :type_id,  :class_name => 'BizCalendar::HolidayType'

  validates_presence_of :state, :type_id
  validate :dates_range
#  validate :ended_setting
  
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
      return "#{self.holiday_start_date.strftime("%Y-%m-%d")}～#{self.holiday_end_date.strftime("%Y-%m-%d")}"
    end
  end

  def target_date_label(format = "%Y-%m-%d")
    if repeat_type.blank?
      self.holiday_start_date = self.holiday_end_date if self.holiday_start_date.blank?
      self.holiday_end_date = self.holiday_start_date if self.holiday_end_date.blank?

      if self.holiday_start_date == self.holiday_end_date
        format = localize_wday(format, self.holiday_start_date.wday)
        return self.holiday_start_date.strftime(format)
      else
        format1 = localize_wday(format, self.holiday_start_date.wday)
        format2 = localize_wday(format, self.holiday_end_date.wday)
        return "#{self.holiday_start_date.strftime(format1)}～#{self.holiday_end_date.strftime(format2)}"
      end
    end
    return ''
  end

  def localize_wday(style, wday)
    style.gsub('%A', I18n.t('date.day_names')[wday]).gsub('%a', I18n.t('date.abbr_day_names')[wday])
  end

  def dates_range
    return if self.holiday_start_date.blank? && self.holiday_end_date.blank?
    self.holiday_start_date = self.holiday_end_date if self.holiday_start_date.blank?
    self.holiday_end_date = self.holiday_start_date if self.holiday_end_date.blank?
    errors.add(:holiday_end_date, "が#{self.class.human_attribute_name :holiday_start_date}を過ぎています。") if self.holiday_end_date < self.holiday_start_date
  end

#  def ended_setting
#    return if self.repeat_type.blank?
#    return if self.end_type == 0
#
#    if self.end_type == 1
#      if self.end_times.blank?
#        errors.add(:end_times, "を選択してください。")
#      elsif self.end_times !~ /^[0-9]+$/
#        errors.add(:end_times, "は半角数字で入力してください。")
#      elsif self.end_times == 0
#        errors.add(:end_times, "は0以上の数値を入力してください。")
#      end
#    end
#
#    if self.end_type == 2
#      errors.add(:end_date, "を入力してください。") if self.end_date.blank?
#    end
#  end

  def set_defaults
    self.state    ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
#    self.end_type ||= END_TYPE_OPTIONS.first.last if self.has_attribute?(:end_type)
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