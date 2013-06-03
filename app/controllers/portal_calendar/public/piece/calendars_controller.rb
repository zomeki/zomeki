# encoding: utf-8
class PortalCalendar::Public::Piece::CalendarsController < Sys::Controller::Public::Base
  def index
    year = params[:year].to_i
    month = params[:month].to_i
    
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
      year = @calendar.year
      month = @calendar.month
    end
    
    @content  = PortalCalendar::Content::Base.find(Page.current_piece.content_id)
    @node = @content.event_node
    uri = @node ? @node.public_uri : '/'
    @calendar.year_uri  = "#{uri}:year/"
    @calendar.month_uri = "#{uri}:year/:month/"
    @calendar.day_uri   = "#{uri}:year/:month/#day:day"
    
    @events = nil
    dates = []
    if @node
      first_date = Date.new(year, month, 1)
      last_date = (first_date >> 1) - 1
      @events = PortalCalendar::Event.get_period_records_with_content_id(@content.id, first_date, last_date)
      @events.each do |event|
        dates << event.get_event_dates
      end
      dates.flatten!.uniq! if dates.size > 0
    end
    
    @calendar.day_link = dates
  end
end
