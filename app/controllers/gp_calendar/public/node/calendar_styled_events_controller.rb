# encoding: utf-8
class GpCalendar::Public::Node::CalendarStyledEventsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = GpCalendar::Content::Event.find_by_id(@node.content.id)
    return http_error(404) unless @content

    @today = Date.today
    @min_date = @today.beginning_of_month
    @max_date = 11.months.since(@min_date)

    return http_error(404) unless validate_date
  end

  def index
    criteria = {month: @date.strftime('%Y%m')}
    @events = GpCalendar::Event.public.all_with_content_and_criteria(@content, criteria)

    start_date = @date.beginning_of_month.beginning_of_week(:sunday)
    end_date = @date.end_of_month.end_of_week(:sunday)

    @weeks = []
    (start_date..end_date).each do |day|
      @weeks.push([]) if @weeks.empty? || day.wday.zero?
      @weeks.last.push(day)
    end
  end

  private

  def validate_date
    @month = params[:month].to_i
    @month = @today.month if @month.zero?
    return false unless @month.between?(1, 12)

    @year = params[:year].to_i
    @year = @today.year if @year.zero?
    return false unless @year.between?(1900, 2100)

    @date = Date.new(@year, @month, 1)
    return @date.between?(@min_date, @max_date)
  end
end
