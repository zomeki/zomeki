# encoding: utf-8
class BizCalendar::BussinessHoliday < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include BizCalendar::Model::Base::Date

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  REPEAT_OPTIONS = [['毎日', 'daily'], ['平日（月～金）', 'weekday'], ['土日祝日', 'saturdays'], ['祝日', 'holiday'],
    ['毎週', 'weekly'], ['毎月', 'monthly'], ['毎年', 'yearly']]
  REPEAT_WEEK_OPTIONS = [['月', 'mon'], ['火', 'tue'], ['水', 'wed'], ['木', 'thurs'], ['金', 'fri'], ['土', 'sat'],['日', 'sun']]
  REPEAT_CRITERION_OPTIONS = [['日付', 'day'], ['曜日', 'week']]
  END_TYPE_OPTIONS = [['なし', 0], ['回数指定', 1], ['日指定', 2]]

  belongs_to :status, :foreign_key => :state,    :class_name => 'Sys::Base::Status'
  belongs_to :place,  :foreign_key => :place_id, :class_name => 'BizCalendar::Place'
  belongs_to :type,   :foreign_key => :type_id,  :class_name => 'BizCalendar::HolidayType'

  validates_presence_of :state, :type_id
  validate :dates_range
  validate :repeat_setting
  validate :ended_setting
  
  after_initialize :set_defaults

  attr_accessor :repeat_num

  scope :public, where(state: 'public')

  def self.all_with_place_and_criteria(place, criteria)
    holidays = self.arel_table

    rel = self.where(holidays[:place_id].eq(place.id))

    if criteria[:repeat_type]
      case criteria[:repeat_type]
      when ''
        rel = rel.where(holidays[:repeat_type].eq('').or(holidays[:repeat_type].eq(nil)))
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
        rel = rel.where(holidays[:repeat_type].not_eq(nil))
        if (s_ym = criteria[:start_year_month]) =~ /^(\d{6})$/ && (e_ym = criteria[:end_year_month]) =~ /^(\d{6})$/
          start_date = Date.new(s_ym.slice(0, 4).to_i, s_ym.slice(4, 2).to_i, 1)
          end_date = Date.new(e_ym.slice(0, 4).to_i, e_ym.slice(4, 2).to_i, 1)
          end_date = end_date.end_of_month
          if start_date && end_date
            rel = rel.where(holidays[:start_date].lteq(end_date).and(holidays[:start_date].gteq(start_date)))

            end_type_rel = holidays[:end_type].eq(0)
            end_type_rel = end_type_rel.or(holidays[:end_type].eq(1))
            end_type_rel = end_type_rel.or(holidays[:end_type].eq(2).and(holidays[:end_date].lteq(end_date)))
            rel = rel.where(end_type_rel)
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

  def repeat_type_text
    REPEAT_OPTIONS.detect{|o| o.last == self.repeat_type }.try(:first).to_s
  end

  def repeat_criterion_text
    REPEAT_CRITERION_OPTIONS.detect{|o| o.last == self.repeat_criterion }.try(:first).to_s
  end

  def get_wday(str=nil)
    list = {'mon' => 1, 'tue' => 2, 'wed' => 3, 'thurs' => 4, 'fri' => 5, 'sat' => 6, 'sun' => 0}
    return str.blank? ? false : list[str]
  end

  def check(day, week_index=false)
    return false if start_date > day
    return false if end_type == 2 && end_date < day

    case repeat_type
    when 'daily'
      if repeat_interval > 1
        return false if self.get_repeat_dates.select {|dt| dt == day }.size < 1
      end
    when 'weekday'
      return false if (day.wday == 0 || day.wday == 6 || Util::Date::Holiday.holiday?(day.year, day.month, day.day, wday = nil))
    when 'holiday'
      return false unless Util::Date::Holiday.holiday?(day.year, day.month, day.day, wday = nil)
    when 'saturdays'
      return false unless (day.wday == 0 || day.wday == 6 || Util::Date::Holiday.holiday?(day.year, day.month, day.day, wday = nil))
    when 'weekly'
      return false unless repeat_week_ary.map {|w| get_wday(w[0]) }.include?(day.wday)
      if repeat_interval > 1
        return false if self.get_repeat_dates.select {|dt| dt == day }.size < 1
      end
    when 'monthly'
      if repeat_criterion == 'day'
        return false if start_date.strftime('%d').to_i != day.day
      else
        return false if start_date.wday != day.wday
        sd_wn =  get_day_of_week_index(start_date)
        s_wn =  get_day_of_week_index(day)
        return false if sd_wn != s_wn
      end
    when 'yearly'
      return false if repeat_interval > 1
      return false if "#{start_date.strftime('%m%d')}" != "#{day.strftime('%m%d')}"
    end

    if end_type == 0
      return true
    elsif end_type == 1
      @repeat_end_num = @repeat_end_num.blank? ? 1 : @repeat_end_num+1
      return true if @repeat_end_num <= self.end_times
    else
      return true if day <= end_date
    end
    return false
  end

  def get_repeat_dates
    return @repeat_dates if @repeat_dates.present?

    dt = start_date
    _dates = []
    _dates << start_date

    # 回数指定
    case repeat_type
    when 'daily'
      _interval = 86400 * repeat_interval
      if end_type == 1
        end_times.times {
          dt = dt + _interval
          _dates << dt
        }
      else

      end
    when 'weekly'
      _interval = 86400 * 7 * repeat_interval
    when 'monthly'
    end

    @repeat_dates = _dates
    return @repeat_dates
  end

  def weeks
    repeat_week.collect{|c| c[0]}
  end

  def repeat_week_ary
    return @rw if @rw.present?
    rw_string = self.repeat_week
    rw = rw_string.kind_of?(String) ? YAML.load(rw_string) : {}.with_indifferent_access
    rw = {}.with_indifferent_access unless rw.kind_of?(Hash)
    rw = rw.with_indifferent_access unless rw.kind_of?(ActiveSupport::HashWithIndifferentAccess)
    rw.delete('_')
    @rw = rw
    return @rw
  end

  def repeat_weeks
    repeat_week_ary.map{ |w| REPEAT_WEEK_OPTIONS.detect{|o| o.last == w[0] }.try(:first).to_s }
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
    else
      end_text = ''
      end_text = " #{end_times}回" if end_type == 1
      end_text = " #{end_date.strftime('%Y年%m月%d日')}まで" if end_type == 2

      case repeat_type
      when 'weekday','saturdays','holiday'
        return "#{repeat_type_text}#{end_text}"
      when 'daily'
        return "#{repeat_interval}日ごと" if repeat_interval > 1
        return "#{repeat_type_text}#{end_text}"
      when 'weekly'
        str = repeat_interval > 1 ? "#{repeat_interval}週間ごと" : repeat_type_text
        str = "#{str} #{repeat_weeks.join('曜日，')}曜日"
        return "#{str}#{end_text}"
      when 'monthly'
        str = repeat_interval > 1 ? "#{repeat_interval}ヶ月ごと" : repeat_type_text
        if repeat_criterion == 'day'
          str = "#{str} #{start_date.strftime('%d').to_i}日"
        else
          wn =  get_day_of_week_index(start_date)
          str = "#{str} 第 #{wn} #{I18n.t('date.abbr_day_names')[start_date.wday]}曜日"
        end
        return "#{str}#{end_text}"
      when 'yearly'
        return "#{repeat_type_text} #{start_date.strftime('%m月%d日')} #{end_text}"
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

  def repeat_setting
    return if self.repeat_type.blank?

    errors.add(:start_date, :blank) if self.start_date.blank?
    case repeat_type
    when 'weekly'
      errors.add(:repeat_week, :blank) if self.repeat_week.blank?
    when 'monthly'
      errors.add(:repeat_criterion, :blank) if self.repeat_criterion.blank?
    end
  end

  def ended_setting
    return if self.repeat_type.blank?
    return if self.end_type == 0

    if self.end_type == 1
      if self.end_times.blank?
        errors.add(:end_times, "を選択してください。")
      elsif self.end_times.to_s !~ /^[0-9]+$/
        errors.add(:end_times, "は半角数字で入力してください。")
      elsif self.end_times == 0
        errors.add(:end_times, "は0以上の数値を入力してください。")
      end
    end

    if self.end_type == 2
      errors.add(:end_date, "を入力してください。") if self.end_date.blank?
    end
  end

  def set_defaults
    self.state    ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.end_type ||= END_TYPE_OPTIONS.first.last if self.has_attribute?(:end_type)
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