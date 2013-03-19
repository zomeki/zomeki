# encoding: utf-8
class GpCalendar::Public::Node::EventsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = GpCalendar::Content::Event.find_by_id(@node.content.id)
    return http_error(404) unless @content

    @today = Date.today
    @min_date = @today.beginning_of_month
    @max_date = @min_date.since(11.months).to_date

    return http_error(404) unless validate_date
  end

  def index
    index_monthly
    render :index_monthly unless Page.mobile?
  end

  def index_monthly
    sdate = Date.new(@year, @month, 1)
    return http_error(404) unless sdate.between?(@min_date, @max_date)
    edate = sdate.since(1.month).to_date

    @calendar = Util::Date::Calendar.new(@year, @month)
    @calendar.month_uri = "#{@node.public_uri}:year/:month/"

    @items = {}
    @calendar.days.each {|d| @items[d[:date]] = [] if d[:month] == @month }

    event_docs(sdate, edate).each do |event|
      @items[event.event_date.to_s] << event
    end

    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = '前の月'
    @pagination.next_label = '次の月'
    @pagination.prev_uri = @calendar.prev_month_uri if @calendar.prev_month_date >= @min_date
    @pagination.next_uri = @calendar.next_month_uri if @calendar.next_month_date <= @max_date

    render :index_monthly_mobile if Page.mobile?
  end

  def index_yearly
    return http_error(404) unless @year.between?(@min_date.year, @max_date.year)
    sdate = Date.new(@year, 1, 1)
    edate = sdate.since(1.year).to_date

    @days  = []
    @items = {}

    wdays = Util::Date::Calendar.wday_specs

    event_docs(sdate, edate).each do |event|
      unless @items.has_key?(event.event_date.to_s)
        date = event.event_date
        wday = wdays[date.wday]
        day  = {
            :date_object => date,
            :date        => date.to_s,
            :class       => "day #{wday[:class]}",
            :wday_label  => wday[:label],
            :holiday     => Util::Date::Holiday.holiday?(date.year, date.month, date.day) || nil
          }
        day[:class].concat(' holiday') if day[:holiday]
        @days << day
        @items[event.event_date.to_s] = []
      end
      @items[event.event_date.to_s] << event
    end

    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = '前の年'
    @pagination.next_label = '次の年'
    @pagination.prev_uri = "#{@node.public_uri}#{@year - 1}/" if (@year - 1) >= @min_date.year
    @pagination.next_uri = "#{@node.public_uri}#{@year + 1}/" if (@year + 1) <= @max_date.year
  end

  private

  def validate_date
    @month = params[:month].to_i
    @month = @today.month if @month.zero?
    return false unless @month.between?(1, 12)

    @year = params[:year].to_i
    @year = @today.year if @year.zero?
    return false unless @year.between?(1000, 9999)

    params[:gp_calendar_event_year]     = @year
    params[:gp_calendar_event_month]    = @month
    params[:gp_calendar_event_min_date] = @min_date
    params[:gp_calendar_event_max_date] = @max_date

    return true
  end

  def event_docs(sdate, edate)
    doc_contents = Cms::ContentSetting.where(name: 'gp_calendar_content_event_id', value: @content.id).map(&:content)
    doc_contents.reject! {|dc| dc.site != Page.site }
    return doc_contents if doc_contents.empty?

    doc_contents.map {|dc|
      case dc.model
      when 'GpArticle::Doc'
        dc = GpArticle::Content::Doc.find(dc.id)
        docs = dc.public_docs.table
        dc.public_docs.where(event_state: 'visible').where(docs[:event_date].gteq(sdate).and(docs[:event_date].lt(edate)))
      else
        []
      end
    }.flatten
  end
end
