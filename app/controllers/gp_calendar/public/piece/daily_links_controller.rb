# encoding: utf-8
class GpCalendar::Public::Piece::DailyLinksController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCalendar::Piece::DailyLink.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    year     = params[:gp_calendar_event_year]
    month    = params[:gp_calendar_event_month]
    min_date = params[:gp_calendar_event_min_date]
    max_date = params[:gp_calendar_event_max_date]

    unless year && month
      today = Date.today
      year = today.year
      month = today.month
      min_date = today.beginning_of_month
      max_date = min_date.since(11.months).to_date
    end

    sdate = Date.new(year, month, 1)
    edate = sdate.since(1.month).to_date

    @calendar = Util::Date::Calendar.new(year, month)

    return unless (@node = @piece.content.event_node)

    @calendar.year_uri  = "#{@node.public_uri}:year/"
    @calendar.month_uri = "#{@node.public_uri}:year/:month/"
    @calendar.day_uri   = "#{@node.public_uri}:year/:month/#day:day"

    dates = []
    event_docs(sdate, edate).each do |event|
      dates << event.event_date
    end
    @calendar.day_link = dates

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

  def event_docs(sdate, edate)
    doc_contents = Cms::ContentSetting.where(name: 'gp_calendar_content_event_id', value: @piece.content.id).map(&:content)
    doc_contents.reject! {|dc| dc.site != Page.site }
    return [] if doc_contents.empty?

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
