# encoding: utf-8
module BizCalendar::BizCalendarHelper
  def localize_ampm(style, time)
    style.gsub!('%H', '%I') if style =~ /%P/
    style.gsub('%P', I18n.t("time.#{time.strftime('%P')}"))
  end


end
