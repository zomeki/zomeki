# encoding: utf-8
class BizCalendar::BussinessHour < ActiveRecord::Base
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

  validates_presence_of :state, :business_hours_start_time, :business_hours_end_time, :end_type
  validate :dates_range
  validate :repeat_setting
  validate :ended_setting
  
  after_initialize :set_defaults

  scope :public, where(state: 'public')


  def check(day, week_index=false)
    return false if repeat_type != '' && start_date > day
    return false if end_type == 2 && end_date < day

    unless repeat_type == ''
      return self.get_repeat_dates.include?(day)
    else
      return day.between?(self.fixed_start_date, self.fixed_end_date)
    end
  end

  def get_repeat_dates(sdate = nil)
    return @all_repeat_dates if sdate.blank? && @all_repeat_dates.present?
    return @repeat_dates if sdate && @repeat_dates.present?

    # end_type = 0:なし, 1:回数指定, 2:日指定
    # repeat_criterion = day:日付, week:曜日

    edate = end_type == 2 ? end_date : false

    dt = start_date
    _dates = []

    if sdate && edate && edate < dt
      @all_repeat_dates = []
      @repeat_dates = []
      return []
    end

    count = 0

    # 回数指定
    case repeat_type
    when 'daily'
      limit = if end_type == 0 || end_type == 2
        364
      elsif end_type == 1
        end_times
      end
      while(_dates.size < limit) do
        dt = dt + repeat_interval if count > 0
        count += 1
        break if edate && edate < dt
        next if end_type != 1 && sdate && sdate > dt
        _dates << dt
      end
    when 'weekday'
      limit = if end_type == 0 || end_type == 2
        365
      elsif end_type == 1
        end_times
      end
      while(_dates.size < limit) do
        dt = dt + 1 if count > 0
        count += 1
        next if (dt.wday == 0 || dt.wday == 6 || Util::Date::Holiday.holiday?(dt.year, dt.month, dt.day, dt.wday))
        break if edate && edate < dt
        next if end_type != 1 && sdate && sdate > dt
        _dates << dt
      end
    when 'saturdays', 'holiday'
      limit = if end_type == 0 || end_type == 2
        365
      elsif end_type == 1
        end_times
      end
      while(_dates.size < limit) do
        dt = dt + 1 if count > 0
        count += 1
        if repeat_type == 'saturdays'
          next if !Util::Date::Holiday.holiday?(dt.year, dt.month, dt.day, dt.wday) && (dt.wday != 0 && dt.wday != 6)
        else
          next if !Util::Date::Holiday.holiday?(dt.year, dt.month, dt.day, dt.wday)
        end
        break if edate && edate < dt
        next if end_type != 1 && sdate && sdate > dt
        _dates << dt
      end
    when 'weekly'
      limit = if end_type == 0 || end_type == 2
        53
      elsif end_type == 1
        end_times
      end
      _interval = 7 * repeat_interval
      dt = dt.beginning_of_week
      t = dt
      while(_dates.size < limit) do
        7.times do
          dt = dt + 1 if count > 0
          count += 1
          next unless repeat_week_ary.map {|w| get_wday(w[0]) }.include?(dt.wday)
          next if end_type != 1 && sdate && sdate > dt
          break if edate && edate < dt
          _dates << dt
        end
        break if edate && edate < dt
        (repeat_interval-1).times { dt = dt.next_week }
        break if edate && edate < dt
      end
    when 'monthly'
      limit = if end_type == 0 || end_type == 2
        24
      elsif end_type == 1
        end_times
      end
      if repeat_criterion == 'day'
        day = start_date.strftime('%d').to_i
        dt = dt.beginning_of_month
        dtx = dt
        while(_dates.size < limit) do
          dtx = dt >> repeat_interval if count > 0
          count += 1
          dt = Date.new(dtx.year, dtx.month, day) if Date.valid_date?(dtx.year, dtx.month, day)
          next if end_type != 1 && sdate && sdate > dt
          _dates << dt
        end
      else
        while(_dates.size < limit) do
          dt = dt >> repeat_interval if count > 0
          count += 1
          week_index =  get_day_of_week_index(start_date)
          dt = get_week_index_of_day(dt.year, dt.month, week_index, start_date.wday)
          break if edate && edate < dt
          next if end_type != 1 && sdate && sdate > dt
          _dates << dt if dt
        end
      end
    when 'yearly'
      limit = if end_type == 0 || end_type == 2
        11
      elsif end_type == 1
        end_times
      end
      mon = start_date.month
      day = start_date.day
      dt = dt.beginning_of_month
      dtx = dt
      while(_dates.size < limit) do
        dtx = dt >> repeat_interval*12 if count > 0
        count += 1
        dt = Date.new(dtx.year, mon, day) if Date.valid_date?(dtx.year, mon, day)
        break if edate && edate < dt
        next if end_type != 1 && sdate && sdate > dt
        _dates << dt if dt
      end
    end

    @all_repeat_dates = _dates
    @repeat_dates = _dates.select {|d| d >= sdate } if sdate

    return sdate.blank? ? @all_repeat_dates : @repeat_dates
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

  def fixed_date
    return '' if self.fixed_start_date.blank? && self.fixed_end_date.blank?

    if self.fixed_start_date == self.fixed_end_date
      return self.fixed_start_date.strftime("%Y-%m-%d")
    else
      return "#{self.fixed_start_date.strftime("%Y-%m-%d")}～#{self.fixed_end_date.strftime("%Y-%m-%d")}"
    end
  end

  def target_date_label(format = "%Y-%m-%d")
    if repeat_type.blank?
      self.fixed_start_date = self.fixed_end_date if self.fixed_start_date.blank?
      self.fixed_end_date = self.fixed_start_date if self.fixed_end_date.blank?

      if self.fixed_start_date == self.fixed_end_date
        format = localize_wday(format, self.fixed_start_date.wday)
        return self.fixed_start_date.strftime(format)
      else
        format1 = localize_wday(format, self.fixed_start_date.wday)
        format2 = localize_wday(format, self.fixed_end_date.wday)
        return "#{self.fixed_start_date.strftime(format1)}～#{self.fixed_end_date.strftime(format2)}"
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
    return if self.fixed_start_date.blank? && self.fixed_end_date.blank?
    self.fixed_start_date = self.fixed_end_date if self.fixed_start_date.blank?
    self.fixed_end_date = self.fixed_start_date if self.fixed_end_date.blank?
    errors.add(:fixed_end_date, "が#{self.class.human_attribute_name :fixed_start_date}を過ぎています。") if self.fixed_end_date < self.fixed_start_date
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
    self.repeat_criterion ||= REPEAT_CRITERION_OPTIONS.first.last if self.has_attribute?(:repeat_criterion)
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