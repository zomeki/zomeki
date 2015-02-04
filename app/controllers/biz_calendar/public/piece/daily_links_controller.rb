# encoding: utf-8
class BizCalendar::Public::Piece::DailyLinksController < BizCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = BizCalendar::Piece::DailyLink.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    date     = params[:biz_calendar_event_date]
    min_date = params[:biz_calendar_event_min_date]
    max_date = params[:biz_calendar_event_max_date]

    unless date
      date = Date.today
      min_date = 1.year.ago(date.beginning_of_month)
      max_date = 11.months.since(date.beginning_of_month)
    end

    start_date = date.beginning_of_month.beginning_of_week(:sunday)
    end_date = date.end_of_month.end_of_week(:sunday)

    @calendar = Util::Date::Calendar.new(date.year, date.month)
#    @calendar.set_event_class = true

    return unless (@node = @piece.target_node)

    @calendar.year_uri  = "#{@node.public_uri}:year/"
    @calendar.month_uri = "#{@node.public_uri}:year/:month/"
    @calendar.day_uri   = "#{@node.public_uri}:year/:month/#day:day"

    days = event_docs(start_date, end_date).inject([]) do |dates, doc|
             dates | (doc.event_started_on..doc.event_ended_on).to_a
           end

    (start_date..end_date).each do |date|
      unless GpCalendar::Event.public.all_with_content_and_criteria(@piece.content, {date: date}).empty?
        days << date unless days.include?(date)
      end
    end

    @calendar.day_link = days.sort!

    if min_date && max_date
      @pagination = Util::Html::SimplePagination.new
      @pagination.prev_label = '前の月'
      @pagination.separator  = %Q(<span class="separator">|</span> <a href="#{@calendar.current_month_uri}">一覧</a> <span class="separator">|</span>)
      @pagination.next_label = '次の月'
      @pagination.prev_uri   = @calendar.prev_month_uri if @calendar.prev_month_date >= min_date
      @pagination.next_uri   = @calendar.next_month_uri if @calendar.next_month_date <= max_date
    end
  end
end
