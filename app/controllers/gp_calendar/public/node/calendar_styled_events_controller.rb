# encoding: utf-8
class GpCalendar::Public::Node::CalendarStyledEventsController < GpCalendar::Public::Node::BaseController
  def index
    http_error(404) if params[:page]

    criteria = {year_month: @date.strftime('%Y%m')}
    @events = GpCalendar::Event.public.all_with_content_and_criteria(@content, criteria).order(:started_on)

    start_date = @date.beginning_of_month.beginning_of_week(:sunday)
    end_date = @date.end_of_month.end_of_week(:sunday)

    merge_docs_into_events(event_docs(start_date, end_date), @events)

    filter_events_by_specified_category(@events)

    @weeks = (start_date..end_date).inject([]) do |weeks, day|
        weeks.push([]) if weeks.empty? || day.wday.zero?
        weeks.last.push(day)
        next weeks
      end

    @holidays = GpCalendar::Holiday.public.all_with_content_and_criteria(@content, criteria)

  end
end
