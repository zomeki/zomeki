# encoding: utf-8
module BizCalendar::Model::Base::Date
  
  # 第n週目
  def get_week_index(date)
    (date.day + 6 + (date - date.day + 1).wday) / 7
  end

  # 第n曜日
  def get_day_of_week_index(date)
    mw = get_week_index(date)
    d = date - ((mw - 1) * 7)
    if date.month == d.month then
      mw
    else
      mw - 1
    end
  end

  def get_wday(str=nil)
    list = {'mon' => 1, 'tue' => 2, 'wed' => 3, 'thurs' => 4, 'fri' => 5, 'sat' => 6, 'sun' => 0}
    return str.blank? ? false : list[str]
  end

  def get_week_index_of_day(year, month, week, wday)
    w  = Date.new(year, month, 1).wday

    first = (wday - w >= 0) ? 1 + wday - w : 1 + wday - w + 7
    day = first + (7 * (week - 1))

    date = Date.new(year, month, day)
    return date
  end

  def localize_wday(style, wday)
    style.gsub('%A', I18n.t('date.day_names')[wday]).gsub('%a', I18n.t('date.abbr_day_names')[wday])
  end

  def localize_ampm(style, time)
    style.gsub('%P', I18n.t("time.#{time.strftime('%P')}"))
  end

end