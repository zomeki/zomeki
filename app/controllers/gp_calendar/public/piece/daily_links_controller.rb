# encoding: utf-8
class GpCalendar::Public::Piece::DailyLinksController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCalendar::Piece::DailyLink.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    date     = params[:gp_calendar_event_date]
    min_date = params[:gp_calendar_event_min_date]
    max_date = params[:gp_calendar_event_max_date]

    unless date
      date = Date.today
      min_date = 1.year.ago(date.beginning_of_month)
      max_date = 11.months.since(date.beginning_of_month)
    end

    start_date = date.beginning_of_month
    end_date = start_date.end_of_month

    @calendar = Util::Date::Calendar.new(date.year, date.month)

    return unless (@node = @piece.content.public_node)

    @calendar.year_uri  = "#{@node.public_uri}:year/"
    @calendar.month_uri = "#{@node.public_uri}:year/:month/"
    @calendar.day_uri   = "#{@node.public_uri}:year/:month/#day:day"

    days = event_docs(start_date, end_date).inject([]) do |dates, event|
             dates << event.event_date
             next dates
           end

    (min_date..min_date.end_of_month).each do |date|
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

  private

  def event_docs(start_date, end_date)
    doc_contents = Cms::ContentSetting.where(name: 'gp_calendar_content_event_id', value: @piece.content.id).map(&:content)
    doc_contents.select! {|dc| dc.site == Page.site }
    return [] if doc_contents.empty?

    doc_contents.map {|dc|
      case dc.model
      when 'GpArticle::Doc'
        dc = GpArticle::Content::Doc.find(dc.id)
        docs = dc.public_docs.table
        dc.public_docs.where(event_state: 'visible').where(docs[:event_date].gteq(start_date).and(docs[:event_date].lteq(end_date)))
      else
        []
      end
    }.flatten
  end
end
