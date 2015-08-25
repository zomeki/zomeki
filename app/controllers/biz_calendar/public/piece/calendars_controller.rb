# encoding: utf-8
class BizCalendar::Public::Piece::CalendarsController < BizCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = BizCalendar::Piece::Calendar.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    @place = @piece.place
    @today = Date.today

    @months = []
    @month_num = @piece.month_number

    dt = @today.beginning_of_month
    @months << dt
    1.upto(@month_num-1).each do |i|
      @months << (dt + i.months)
    end
    started = @months.first
    ended   = @months.last

    @weeks    = Hash.new()
    @months.each do |month|
      start_date = month.beginning_of_month.beginning_of_week(:sunday)
      end_date = month.end_of_month.end_of_week(:sunday)

      @weeks["#{month.strftime('%Y%m')}"] = (start_date..end_date).inject([]) do |weeks, day|
          weeks.push([]) if weeks.empty? || day.wday.zero?
          weeks.last.push(day)
          next weeks
        end
    end

    if @place
      criteria = {repeat_type: '', start_year_month: started.strftime('%Y%m'), end_year_month: ended.strftime('%Y%m')}
      @holidays           = BizCalendar::BussinessHoliday.public.all_with_place_and_criteria(@place, criteria).order(:holiday_start_date)
      @exception_holidays = BizCalendar::ExceptionHoliday.public.all_with_place_and_criteria(@place, criteria).order(:start_date)

      criteria[:repeat_type] = 'not_null'
      @repeat_holidays = BizCalendar::BussinessHoliday.public.all_with_place_and_criteria(@place, criteria).order(:holiday_start_date)
    end
    
  end
  
end
