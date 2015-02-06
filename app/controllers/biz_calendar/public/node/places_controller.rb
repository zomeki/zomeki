# encoding: utf-8
class BizCalendar::Public::Node::PlacesController < BizCalendar::Public::Node::BaseController
  skip_filter :render_public_layout, :only => [:file_content]

  def index
    http_error(404) if params[:page]

    @places = @content.public_places

    @months = []
    @month_num = @content.month_number

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

    @holidays = Hash.new()
    @exception_holidays = Hash.new()
    @places.each do |place|
      criteria = {repeat_type: '', start_year_month: started.strftime('%Y%m'), end_year_month: ended.strftime('%Y%m')}
      @holidays[place.id]           = BizCalendar::BussinessHoliday.public.all_with_place_and_criteria(place, criteria).order(:holiday_start_date)
      @exception_holidays[place.id] = BizCalendar::ExceptionHoliday.public.all_with_place_and_criteria(place, criteria).order(:start_date)

#      criteria[:repeat_type] = 'not_null'
#      holidays2           = BizCalendar::BussinessHoliday.public.all_with_place_and_criteria(place, criteria).order(:holiday_start_date)
#      exception_holidays2 = BizCalendar::ExceptionHoliday.public.all_with_place_and_criteria(place, criteria).order(:start_date)
    end
  end

  def show
    http_error(404) unless @place = @content.public_places.where(url: params[:name]).first

    Page.current_item = @place
    Page.title = "#{@place.title}"

    @months = []
    @month_num = @content.show_month_number

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

    @holidays = Hash.new()
    @exception_holidays = Hash.new()
    
    criteria = {repeat_type: '', start_year_month: started.strftime('%Y%m'), end_year_month: ended.strftime('%Y%m')}
    @holidays[@place.id]           = BizCalendar::BussinessHoliday.public.all_with_place_and_criteria(@place, criteria).order(:holiday_start_date)
    @exception_holidays[@place.id] = BizCalendar::ExceptionHoliday.public.all_with_place_and_criteria(@place, criteria).order(:start_date)

  end

end
